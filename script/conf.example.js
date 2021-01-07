module.exports = {
  config: {
    name: 'service',
    baseUrl: 'http://localhost:8088',
    apiKey: 'kJyjfBXSGF8nOzcZzeiNZNcTHZuKjtcV',
    zookeeper: '127.0.0.1:22181',
    prefix: '/healthchecks2',
  },
  projects: [
    {
      name: 'deleteExpiredComments',
      tags: 'job dev live-schedule',
      desc: '定时删除7天前的评论',
      timeout: 60,
      grace: 3600,
      schedule: '31 * * * *',
      tz: 'Asia/Shanghai',
      unique: ['name'],
      type: 'job',
    },
    {
      name: 'http-server',
      tags: 'service prd',
      desc: 'http service',
      timeout: 60,
      grace: 60,
      schedule: '* * * * *',
      tz: 'Asia/Shanghai',
      unique: ['name'],
      type: 'svc',
      host: ['10.11.11.165', '10.11.11.166', '10.11.11.167'],
      port: 8000,
      path: '/healthz',
    },
  ],
}