const mysql = require('mysql')
const express = require('express')
const app = express()
const port = 3001

//Lösung von dieser Seite erhalten: https://create-react-app.dev/docs/proxying-api-requests-in-development/
app.use(function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "http://localhost:3000"); // update to match the domain you will make the request from
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
    //res.header("Access-Control-Allow-Origin", "http://localhost:3000"); //evt. muss hier der andere server stehen
    //res.header("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT");
    //res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
});

app.get('/hierarchy', (req, res) => {
    const connection = mysql.createConnection({
        host: 'localhost',
        user: 'expressjs_user',
        password: 'password',
        database: 'hierarchie_test'
    })

    connection.connect()

    connection.query('SELECT fun_children_tree_as_json() as children_tree', (err, rows, fields) => {
        if (err) throw err
        let children_tree = JSON.parse(rows[0].children_tree);
        res.send(children_tree);
    })

    connection.end()
})

app.listen(port, () => {
    console.log(`App listening on port ${port}`)
})