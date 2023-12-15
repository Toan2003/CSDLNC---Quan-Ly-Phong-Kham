const sql = require ('mssql');

const sqlConfig = {
    user: 'ADMIN',
    password: '123456',
    database: 'QLPK_CSDL',
    server: 'localhost',
    pool: {
      max: 10,
      min: 0,
      idleTimeoutMillis: 30000
    },
    options: {
      requestTimeout: 150000,
      encrypt: true, // for azure
      trustServerCertificate: true // change to true for local dev / self-signed certs
    },
    requestTimeout: 150000,
}

async function connectToSQL(){
    await sql.connect(sqlConfig)
    // const result = await sql.query`select * from KEHOACHDIEUTRI `
    // console.log(result)
    .then(()=>{console.log("CONNECTION OPEN")})
    .catch(err=>{
        console.log("Error connecting to sql")
        console.log(err)
})
}
connectToSQL();
module.exports = {connectToSQL}