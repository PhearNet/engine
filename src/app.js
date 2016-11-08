/**
 * Startup Info
 */

var newrelic = require('newrelic');
//Passed in paramaters
process.argv.forEach(function(val, index, array) {
    console.log(index + ': ' + val);
});

//Temporary benchmark function for execution time
var logTime = function(time) {
    var diff = process.hrtime(time);
    // console.log('benchmark took %d nanoseconds', diff[0] * 1e9 + diff[1]);
}

// Get Memory usage
var util = require('util');
console.log(util.inspect(process.memoryUsage()));


/**
 *  Instance Globals
 */
var INSTANCE = {
    process: {
        verisons: process.versions,
        title: process.title,
        pid: process.pid,
    },
    startTime: process.hrtime(),
    platform: process.platform,
    arch: process.arch,
    memory: process.memoryUsage(),
    uptime: process.uptime(),

    network: {
        ip: (require('os').networkInterfaces())["eth0"][0].address
    }
};



/**
 * Load the Configuration file and rock N Roll
 */
var fs = require('fs');
var file = __dirname + '/config.json';

fs.readFile(file, 'utf8', function(err, data) {
    if (err) {
        console.log('Error: ' + err);
        newrelic.noticeError(err);
        return;
    }

    CONFIG = JSON.parse(data);
    console.log(CONFIG.keys);

    /**
     * Logging
     */
    var loggly = require('loggly');
    var client = loggly.createClient(CONFIG.keys.logs.loggly);
    client.log('Logger Online');

});

function setupDigitalOcean(clientID, key) {
    //DigitalOcean api
    var DO = require('digitalocean').Api;
    var digitalOcean = new DO(clientID, key);
    //digitalOcean.domains.get("phearzero.com", function(domainlist){
    // console.log("Whaaattupp", domainlist);
    //});


//    //Main id for droplet
//    var dropletId = 12345;
//
//    digitalOcean.droplets.get(dropletId, function(droplet) {
//        // console.log('Droplet #' + dropletId, droplet);
//    });
}

function setupCloudFlare(email, token) {
    //Cloudflare DNS
    var cf = require('cloudflare').createClient({
        email: email,
        token: token
    });

    cf.listDomains(function(err, domains) {
        if (err) throw err;
        domains.forEach(function(domain) {
            var plan = domain.props.plan,
                status = domain.zone_status_class.replace('status-', '');

            console.log("Domain: %s, plan: %s, status: %s", domain.display_name, plan,
                status);
        });
    });

    return cf;

}

/**
 * DNS
 */

function checkDomain(instance) {


};

function setupSubdomain(subdomain) {

    digitalOcean.domains.new({
        name: subdomain,
        ip_address: INSTANCE.network
    }, function(thing) {
        console.log(thing);
    })

    //Cloudflare domain options
    var cfopts = {
        name: subdomain,
        content: INSTANCE.network,
        type: "A",
        ttl: "1"
    };
    cloudflare.addDomainRecord('phearzero.com', cfopts, function(err, res) {
        if (err) {
            console.log(err);
        } else {
            console.log("Added Domain");
        }
    });
}


//nginx Configuration
var reloader = require('nginx-reload');

var nginx = new reloader('/var/run/nginx.pid', function(running) {
    console.log('nginxReloader:', running);


    var NginxConfFile = require('nginx-conf').NginxConfFile;
    //Fetch the default config file

    NginxConfFile.create('/etc/nginx/sites-available/default', function(err,
        conf) {
        //If there is an error break outta here!
        if (err) {
            console.log(err);
            return;
        }

        conf.on('flushed', function() {


            console.log('finished writing to disk');


        });
        // if(conf.nginx.upstream){
        // var serverCount = conf.nginx.upstream.server.length;
        // console.log("ServerCount:", serverCount);
        // conf.nginx.upstream._add('server', '127.0.0.1:3006');
        // }

        // nginx.reload(function(err, stdout, stderr) {
        // if (err) {
        // console.log("ReloadError:", err);
        // }
        //nginx.end();
        // });

        var subdomain = new Date().valueOf() + ".phearzero.com";

        //Docker Controller
        var docker = require('docker.io')({
            socketPath: '/var/run/docker.sock'
        });
        var subdomain = new Date().valueOf() + ".phearzero.com";

        var options = {
            "Hostname": "node01.phearzero.com",
            "Memory": "64M",
            "AttachStdin": false,
            "AttachStdout": true,
            "AttachStderr": true,
            "Image": "ubuntu/nodejs",
            "Cmd": ["nodejs", "phear-reports/app.js"],
            "ExposedPorts": {
                "3001/tcp": {}
            }
        };
        docker.containers.list({
            all: 1
        }, function(err, res) {
            if (err) throw err;
            //console.log(res);
        });
        docker.containers.create(options, function(err, res) {
            if (err) throw err;
            //console.log("data returned from Docker as JS object: ", res);
            //console.log(res.Id);
            //docker.containers.inspect(res.Id, function(err, res) {
            // console.log(res);
            //});

            docker.containers.start(res.Id, function(err, res) {
                if (err)
                    console.log(err);
                console.log(res);

            });
            docker.containers.inspect(res.Id, function(err, res) {
                var docIP = res.NetworkSettings.IPAddress;
                console.log(docIP);

                if (conf.nginx.upstream) {
                    //var serverCount = conf.nginx.upstream.server.length;
                    //console.log("ServerCount:", serverCount);
                    conf.nginx.upstream._add('server', docIP + ':3001');
                }

            });

        });

        //docker.images.list(function(err,res){
        // if (err) throw err;
        // //console.log("data returned from Docker as JS object: ", res);
        //});


        nginx.reload(function(err, stdout, stderr) {
            if (err) {
                console.log("ReloadError:", err);
            }
            //nginx.end();
        });


    });
});

// Next In Loop
process.nextTick(function() {
    console.log('nextTick callback');
});

// var forever = require('forever');
// forever.startDaemon('viewport.js');
