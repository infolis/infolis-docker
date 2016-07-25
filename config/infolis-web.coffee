# console.log process.env

process.env.MONGO_PORT or= '27018'
process.env.MONGO_ADDR or= 'localhost'
process.env.MONGO_DBNAME or= 'infolis-web'
process.env.INFOLINK_ADDR or= 'localhost'
process.env.INFOLINK_PORT or= '8080'

# Production (backend on different server)
# module.exports =
#   basePath: '/infolink'
#   baseURI: 'http://infolis.gesis.org'
#   site_api: 'http://infolis.gesis.org'
#   site_github: 'http://infolis.github.io'
#   backendURI: "http://spkosc03:8090"
#   backendApiPath: 'infoLink-1.0/infolis-api'
#   mongoURI: "mongodb://#{process.env.MONGO_ADDR}:#{process.env.MONGO_PORT}/#{process.env.MONGO_DBNAME}"

# Production (backend on same server)
module.exports =
	basePath: '/infolink'
	baseURI: 'http://infolis.gesis.org/infolink'
	site_api: 'http://infolis.gesis.org/infolink'
	site_github: 'http://infolis.github.io'
	backendURI: "http://#{process.env.INFOLINK_ADDR}:#{process.env.INFOLINK_PORT}"
	backendApiPath: 'infoLink-1.0/infolis-api'
	mongoURI: "mongodb://#{process.env.MONGO_ADDR}:#{process.env.MONGO_PORT}/#{process.env.MONGO_DBNAME}"
	mongoServerOptions:
		server:
			socketOptions:
				keepAlive: 1
				connectTimeoutMS: 60000
			reconnectTries: 60
			reconnectInterval: 4000


# module.exports =
#   basePath: ''
#   baseURI: 'http://infolis-web:3000'
#   site_api: 'http://infolis-web:3000'
#   site_github: 'http://infolis-github:4000'
#   backendURI: "http://#{process.env.INFOLINK_ADDR}:#{process.env.INFOLINK_PORT}"
#   backendApiPath: 'infoLink-1.0/infolis-api'
#   mongoURI: "mongodb://#{process.env.MONGO_ADDR}:#{process.env.MONGO_PORT}/#{process.env.MONGO_DBNAME}"
