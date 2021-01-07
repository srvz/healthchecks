/* eslint-disable import/no-dynamic-require */
/* eslint-disable @typescript-eslint/no-var-requires */
const path = require('path')
const fs = require('fs')
const util = require('util')
const zookeeper = require('node-zookeeper-client')
const { HealthChecksApiClient } = require('healthchecks-io-client')

// npm i node-zookeeper-client healthchecks-io-client

function getFields(o, fileds) {
  const n = {}
  for (const f of fileds) {
    if (o[f]) n[f] = o[f]
  }
  return n
}

async function composeItem(client, project, host) {
  const item = { ...project }
  if (host) {
    item.host = host
    item.name = `${item.name}_${item.host}`
  }
  item.channels = item.channels || '*'
  const params = getFields(item, [
    'name',
    'tags',
    'desc',
    'timeout',
    'grace',
    'schedule',
    'tz',
    'channels',
    'unique',
  ])
  const res = await client.createCheck(params)
  console.log(res)
  if ([200, 201].includes(res.statusCode)) {
    item.ping_url = res.data.ping_url
    item.uuid = item.ping_url.split('ping/').pop()
  }
  if (res.statusCode === 200) {
    delete params.unique
    await client.updateCheck(item.uuid, params)
  }
  return item
}

function createZookeeperClient(address) {
  const client = zookeeper.createClient(address)
  const methods = ['create', 'mkdirp', 'exists', 'setData', 'getData']
  for (const i of methods) {
    client[i] = util.promisify(client[i]).bind(client)
  }
  client.on('connected', async () => {
    console.log('Connected to the server.')
  })
  client.connect()
  return client
}

async function main() {
  try {
    const configPath = path.resolve(process.argv[2])
    const dirname = path.dirname(configPath)
    if (!fs.existsSync(configPath)) {
      throw new Error('File not exists')
    }
    const { config, projects } = require(configPath)
    const client = new HealthChecksApiClient({
      baseUrl: config.baseUrl,
      apiKey: config.apiKey,
      fullResponse: true,
    })
    let zkClient = null
    if (config.zookeeper) {
      zkClient = createZookeeperClient(config.zookeeper)
    }
    const results = []
    for (const proj of projects) {
      if (Array.isArray(proj.host) && proj.host.length) {
        for (const host of proj.host) {
          const item = await composeItem(client, proj, host)
          const dir = `${config.prefix}/${item.name}`
          if (zkClient) {
            await zkClient.mkdirp(dir)
            await zkClient.setData(dir, Buffer.from(item.uuid))
          }
          results.push(item)
        }
      } else {
        const item = await composeItem(client, proj)
        const dir = `${config.prefix}/${item.name}`
        if (zkClient) {
          await zkClient.mkdirp(dir)
          await zkClient.setData(dir, Buffer.from(item.uuid))
        }
        results.push(item)
      }
    }
    if (zkClient) zkClient.close()
    const fp = path.join(dirname, `${config.name}-checks.json`)
    fs.writeFileSync(fp, JSON.stringify(results, null, 2))
  } catch (e) {
    console.error('error =>', e)
  }
  process.exit(0)
}

main()