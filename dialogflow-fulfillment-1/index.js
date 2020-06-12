'use strict';

const functions = require('firebase-functions');
const {WebhookClient} = require('dialogflow-fulfillment');
const rp = require('request-promise');
const {google} = require('googleapis');
const calendarId = 'ENTER_YOUR_ID_HERE';
const calendar = google.calendar('v3');
const timeZone = 'Europe/Kaliningrad';  
const timeZoneOffset = '+02:00'; 
const newsKey = 'ENTER_YOUR_KEY_HERE';
const convertKey = 'ENTER_YOUR_KEY_HERE';
const exchangeKey = 'ENTER_YOUR_KEY_HERE';
const dictionaryKey = 'ENTER_YOUR_KEY_HERE';

const serviceAccount = {
  /* 
  Enter your service account data here
  */
};

const serviceAccountAuth = new google.auth.JWT({
  email: serviceAccount.client_email,
  key: serviceAccount.private_key,
  scopes: 'https://www.googleapis.com/auth/calendar'
});

exports.dialogflowFirebaseFulfillment = functions.https.onRequest((request, response) => {
  const agent = new WebhookClient({ request, response });
  
  function welcome(agent) {
    agent.add('Welcome to the Virtual assistant!');
  }

  function fallback(agent) {
    agent.add(`I didn't get that, can you try again?`);
  }
  
  function makeAppointment (agent) {
    const appointmentDuration = 1;
    const dateTimeStart = new Date(Date.parse(agent.parameters.date.split('T')[0] + 'T' + agent.parameters.time.split('T')[1].split('+')[0] + timeZoneOffset));
    const dateTimeEnd = addHours(dateTimeStart, appointmentDuration);
    const appointmentTimeString = getLocaleTimeString(dateTimeStart);
    const appointmentDateString = getLocaleDateString(dateTimeStart);
   
    return createCalendarEvent(dateTimeStart, dateTimeEnd).then(() => {
      agent.add(`Got it. I have your appointment scheduled on ${appointmentDateString} at ${appointmentTimeString}. See you soon. Good-bye.`);
    }).catch(() => {
      agent.add(`Sorry, we're booked on ${appointmentDateString} at ${appointmentTimeString}. Is there anything else I can do for you?`);
    });
  }
  
  function advice(agent) {
    var options = {
  		uri: 'https://api.adviceslip.com/advice',
        method: 'GET',
        json: true,
	};
	return rp(options)
  		.then( body => {
    			agent.add(body.slip.advice);
  		});
  }
  
  function quote(agent) {
    var options = {
  		uri: 'https://quote-garden.herokuapp.com/api/v2/quotes/random',
        method: 'GET',
        json: true,
	};
	return rp(options)
  		.then( body => {
    			agent.add(body.quote.quoteText);
      			agent.add('Author' + body.quote.quoteAuthor);
  		});
  }
  
  function joke(agent) {
    var options = {
  		uri: 'https://official-joke-api.appspot.com/random_joke',
        method: 'GET',
        json: true,
	};
	return rp(options)
  		.then( body => {
    			agent.add(body.setup);
      			agent.add(body.punchline);
  		});
  }
  
  function number(agent) {
    var options = {
  		uri: 'http://numbersapi.com/' + agent.parameters.number,
        method: 'GET',
        json: false,
	};
	return rp(options)
  		.then( body => {
    			agent.add(body);
  		});
  }
  
  function lyrics(agent) {
    var options = {
  		uri: 'https://api.lyrics.ovh/v1/' + agent.parameters.artist + '/' + agent.parameters.song,
        method: 'GET',
        json: true,
	};
	return rp(options)
  		.then( body => {
    			agent.add(body.lyrics);
  		});
  }
  
  function dict(agent) {
   var options = {
  		uri: 'https://owlbot.info/api/v4/dictionary/' + agent.parameters.word,
        method: 'GET',
        json: true,
      	headers: {
        'Authorization': 'Token ' + dictionaryKey
    	}
	};
	return rp(options)
  		.then( body => {
    			agent.add(body.definitions[0].definition);
  		});
  }
  
  function news(agent) {
     var url = 'https://api.currentsapi.services/v1/search?apiKey=' + newsKey + '&keywords=' + agent.parameters.keyword + '&category=' + agent.parameters.category + '&start_date' + agent.parameters.date + '&domain' + agent.parameters.source;
     var options = {
  		uri: url,
        method: 'GET',
        json: true
	};
	return rp(options)
  		.then( body => {
      			var j;
                for(j=0;j<body.news.length;j++) {
                  agent.add(body.news[j].title + ': ' + body.news[j].url);
                  if(j==4) break;             
                }
  		});
  }
  
   function convert(agent) {
   	const requestOptions = {
  		method: 'GET',
        uri: 'https://api.unitconvert.io/api/v1/Measurements/Convert?from=' + agent.parameters.amount + agent.parameters.from + '&to=' + agent.parameters.to,
        headers: {
          'api-key': convertKey
        },
        json: true
      };

    return rp(requestOptions).then(response => {
        agent.add(response.display);
      }).catch((err) => {
        console.log('API call error:', err.message);
      });
   }
  
   function exchange(agent) {
    var options = {
  		uri: 'https://fcsapi.com/api-v2/forex/latest?symbol=' + agent.parameters.from + '/' + agent.parameters.to + '&access_key=' + exchangeKey,
        method: 'GET',
        json: true
	};
	return rp(options)
  		.then( body => {
            agent.add(''+(parseFloat(body.response[0].price) * agent.parameters.quantity).toFixed(2)+'');
  		});
  }
  
  let intentMap = new Map();
  intentMap.set('Default Welcome Intent', welcome);
  intentMap.set('Default Fallback Intent', fallback);
  intentMap.set('Generate quote', quote);
  intentMap.set('Generate advice', advice);
  intentMap.set('Generate joke', joke);
  intentMap.set('Generate number', number);
  intentMap.set('Generate lyrics', lyrics);
  intentMap.set('Dictionary', dict);
  intentMap.set('News', news);
  intentMap.set('UnitsConvert', convert);
  intentMap.set('Exchange', exchange);
  intentMap.set('Schedule Appointment', makeAppointment);
  agent.handleRequest(intentMap);
});

function createCalendarEvent (dateTimeStart, dateTimeEnd) {
  return new Promise((resolve, reject) => {
    calendar.events.list({  
      auth: serviceAccountAuth,
      calendarId: calendarId,
      timeMin: dateTimeStart.toISOString(),
      timeMax: dateTimeEnd.toISOString()
    }, (err, calendarResponse) => {
      
      if (err || calendarResponse.data.items.length > 0) {
        reject(err || new Error('Requested time conflicts with another appointment'));
      } else {
        calendar.events.insert({ auth: serviceAccountAuth,
          calendarId: calendarId,
          resource: {summary: 'Bike Appointment',
            start: {dateTime: dateTimeStart},
            end: {dateTime: dateTimeEnd}}
        }, (err, event) => {
          err ? reject(err) : resolve(event);
        }
        );
      }
    });
  });
}

function addHours(dateObj, hoursToAdd){
  return new Date(new Date(dateObj).setHours(dateObj.getHours() + hoursToAdd));
}

function getLocaleTimeString(dateObj){
  return dateObj.toLocaleTimeString('en-US', { hour: 'numeric', hour12: true, timeZone: timeZone });
}

function getLocaleDateString(dateObj){
  return dateObj.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', timeZone: timeZone });
}