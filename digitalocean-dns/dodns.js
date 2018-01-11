/*
 * Uses Digital Ocean APIv2.
 *
 */
const https = require('https');
const { URL } = require('url');

const configuration = require('./config/dodns.conf.js');



function fetch(options, payload=null, isJson=true) {
  return new Promise((resolve, reject) => {
    if (typeof payload === 'object') {
      payload = JSON.stringify(payload);
    }

    const req = https.request(options, (res) => {
      res.setEncoding('utf8');
      let body = '';

      res.on('readable', function() {
        // data arrives in one or more chunks
        var chunk = this.read() || '';
        body += chunk;
      });

      res.on('end', function(eee) {
        // check for success
        if (res.statusCode !== 200) {
          reject(`Invalid status code: ${res.statusCode}, message: ${body}`);
        }

        // parse response
        if (isJson) {
          try {
            resolve(JSON.parse(body));
          } catch (e) {
            throw new Error(`Failed to process incoming JSON data${body && `, payload: ${body}`}${e && `, error: ${e}`}`);
          }
        } else {
          resolve(d);
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    if ((options.method === 'POST' || options.method === 'PUT') && payload) {
      console.log('writing', payload);
      req.write(payload);
    }
    req.end();
  });
}


function retreiveDODomainRecords(token, domainName) {
  // DO Domain Record Query Example:
  // curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" "https://api.digitalocean.com/v2/domains/example.com/records"
  const options = {
    host: 'api.digitalocean.com',
    port: '443',
    path: `/v2/domains/${domainName}/records`,
    method: 'GET',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': `Bearer ${token}`,
    },
  };

  return fetch(options);
}


function updateDORecord(token, domainName, domainRecordId, changeset) {
  // DO Domain Record Update API Example:
  // curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582" -d '{"name":"blog"}' "https://api.digitalocean.com/v2/domains/example.com/records/3352896"
  const options = {
    host: 'api.digitalocean.com',
    port: '443',
    path: `/v2/domains/${domainName}/records/${domainRecordId}`,
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': `Bearer ${token}`,
    }
  };

  console.log('Updating', changeset);
  return fetch(options, changeset);
}


function updateDOConfiguration(ip) {
  console.log(`${new Date().toLocaleString()}: Updating Digital Ocean DNS configuration to ${ip}...`);

  const requests = configuration.domains.map((domain) => {
    console.log(`Updating Digital Ocean DNS configuration for ${domain.domain}...`);
    return retreiveDODomainRecords(configuration.doPublicToken, domain.domain)
    .then((domainRecords) => {
      const subdomainRequests = [];
      domain.subdomains.forEach((subdomain) => {
        // find a record for the subdomin
        const doRecord = domainRecords.domain_records.find((record) => record.name === subdomain);
        if (!doRecord || doRecord.type !== 'A') {
          return;
        }

        if (doRecord.data === ip) {
          // already has the same IP, nothing to update.
          console.log(`\t'${subdomain}' already on same IP`);
          return;
        }

        // update the record with the new IP
        const updateRecord = {
          data: ip,
        };

        const updatePromise = updateDORecord(configuration.doPublicToken, domain.domain, doRecord.id, updateRecord)
        .then((response) => console.log(`\t'${subdomain}' updated.`, response));
        subdomainRequests.push(updatePromise);
      });

      if (subdomainRequests.length === 0) {
        console.log('\tno subdomains updated (nothing found, or already on same IP)!');
      }
      return Promise.all(subdomainRequests);
    });
  });

  return Promise.all(requests);
}


function fetchExternalIP() {
  // IP from ipify.org
  // it's a JSON object, format: { "ip": "X.X.X.X" }
  return fetch(new URL('https://api.ipify.org?format=json'))
  .then(response => response.ip);
}



//////////////////////////////////////////////////////////////////////////////////////////////////

// Configuration validation
if (!configuration) {
  console.error('ERR: Missing configuration (it\'s looking for a JS file @ ./config/dodns.conf.js)!');
  return 1;
}
if (!configuration.doPublicToken) {
  console.error('ERR: Invalid configuration, missing Digital Ocean Public API Token!');
  return 1;
}


// Let's go
fetchExternalIP()
.then(updateDOConfiguration)
.catch((error) => {
    console.error('ERR:', error);
});
