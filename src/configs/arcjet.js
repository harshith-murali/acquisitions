import arcjet, { shield, detectBot, tokenBucket } from '@arcjet/node';

const aj = arcjet({
  key: process.env.ARCJET_KEY,

  rules: [
    shield({
      mode: 'LIVE',
    }),

    detectBot({
      mode: 'LIVE',
      allow: ['CATEGORY:SEARCH_ENGINE', 'POSTMAN'],
    }),

    tokenBucket({
      mode: 'LIVE',
      refillRate: 5,
      interval: 10,
      capacity: 10,
    }),
  ],
});

export default aj;
