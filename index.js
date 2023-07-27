const express = require('express');
const { Server } = require('ws');
const axios = require('axios');


const PORT = process.env.PORT || 3000;
const app = express();

// Initialize WebSocket server
const server = app.listen(PORT, () => console.log(`Listening on ${PORT}`));
const wss = new Server({ server });

const { Configuration, OpenAIApi } = require("openai");




// Handle WebSocket connections
wss.on('connection', ws => {
  console.log('WebSocket connected');

  // Listen for incoming messages from the user
  ws.on('message', async message => {

    
    try {
      const data = JSON.parse(message);
      const { text, apiKey } = data;

      // Now you have the input text and the API key, you can use them in the processing function
      const processedText = await processTextFunction(text, apiKey);

      ws.send(JSON.stringify({ processedText }));
    } catch (error) {
      console.error(error);
      ws.send(JSON.stringify({ error: 'An error occurred while processing the text.' }));
    }
  });

  ws.on('close', () => {
    console.log('WebSocket disconnected');
  });
});
async function fetchWebsiteContent(websiteUrl) {
  try {
    const response = await axios.get(websiteUrl);
    return response.data; // Assuming the website returns HTML content
  } catch (error) {
    console.error(error);
    throw new Error('Failed to fetch website content.');
  }
}



async function processTextFunction(text,apiKey) {
 
  const configuration = new Configuration({
    apiKey: apiKey,
  });

  const openai = new OpenAIApi(configuration);
  
  const response = await openai.createCompletion({
    model: 'text-davinci-003',
    prompt: `Read from the website ${text} and generate important points for quick revision covering everything given in the website `,
    temperature: 1,
    max_tokens: 800,
  });

  console.log(response);
  return response.data.choices[0].text;
}
