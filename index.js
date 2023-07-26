//const {processEnv} = require('./env');
const express = require('express');
const app = express();

const { Configuration, OpenAIApi } = require("openai");

const configuration = new Configuration({
  apiKey:  process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);
 // Import the fetch module
const port = 3000;

app.use(express.json());




app.post('/processText', (req, res) => {
  const { text } = req.body;

  // Process the text using the desired function
  processTextFunction(text)
    .then(processedText => {
      res.json({ processedText });
    })
    .catch(error => {
      console.error(error);
      res.status(500).json({ error: 'An error occurred while processing the text.' });
    });
});

app.listen(port,'192.168.1.5',() => {
  console.log(`Server is running on port ${port}`);
});
// instruction object has two key value pairs: role and content
const Conversation =[{
  'role':'system', // tells open ai what comes next is an instruction
  'content':'You are a creative story teller.help develop stories for users'
}]

async function processTextFunction(text) {

  Conversation.push({
    'role':'user',
    'content':text
  })
  const response = await openai.createCompletion({
    model: "text-davinci-003",
    prompt: `Read from the website ${text} and generate short key points for quick revision covering everything given in the site highlighting relevant points. Generate points so as to by heart and be simple and efficient
    `,
    temperature: 0.2,
    max_tokens: 50,
    
   
  });
  console.log(response);
  
  return response.data.choices[0].text;
}





























// app.post('/processImage', (req, res) => {
//   const {img_prompt} = req.body;
//   processImage(img_prompt).then(processedImage => {
//     res.json({ processedImage });
//   })
//   .catch(error => {
//     console.error(error);
//     res.status(500).json({ error: 'An error occurred while processing the image.' });
//   });
// });



// async function processImage(img_prompt) {


//   const response = await openai.createImage({
  
//     prompt: "a painting of a cat sitting on a chair",
//     n:1,
//     size: '256x256',
//     response_format:'url'
   
//   });
//   console.log(response.data.data[0].url);
  
//   return response.data.data[0].url
// }



//prompt: `Write me a detailed step-by-step recipe by a professional chef for something healthy I can make with the following ingredients:\n\n${text}`,
