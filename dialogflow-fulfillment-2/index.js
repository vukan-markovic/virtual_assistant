'use strict';

const http = require('http');
const functions = require('firebase-functions');
const host = 'api.worldweatheronline.com';
const wwoApiKey = 'enter_your_wwo_api_key_here';

exports.dialogflowFirebaseFulfillment = functions.https.onRequest((req, res) => {
  let date = '';
  
  if (req.body.queryResult.parameters.date) {
    date = req.body.queryResult.parameters.date;
  	if (date.substr(0,10)) date = date.substr(0,10);
  	else date = new Date().toJSON().substr(0,10);
  }
  
  callWeatherApi(req.body.queryResult.parameters['geo-city'], date).then((output) => {
    res.json({ 'fulfillmentText': output });
  }).catch(() => {
    res.json({ 'fulfillmentText': `I don't know the weather but I hope it's good!` });
  });
});

function callWeatherApi (city, date) {
  return new Promise((resolve, reject) => {
    http.get({host: host, path: '/premium/v1/weather.ashx?format=json&num_of_days=1&q=' + encodeURIComponent(city) + '&key=' + wwoApiKey + '&date=' + date}, (res) => {
      let body = '';
      res.on('data', (d) => { body += d; }); 
      res.on('end', () => {
        let response = JSON.parse(body);
        let forecast = response.data.weather[0];
        let location = response.data.request[0];
        let output = `Current conditions in the ${location.type} ${location.query} are ${response.data.current_condition[0].weatherDesc[0].value} with a projected high of ${forecast.maxtempC}°C or ${forecast.maxtempF}°F and a low of ${forecast.mintempC}°C or ${forecast.mintempF}°F on ${forecast.date}.`;
        resolve(output);
      });
      res.on('error', (error) => {
        reject();
      });
    });
  });
}