import { Router } from 'express';

const router = Router();

router.get('/', (req, res, next) => {
  return res.render('index', {title: 'Hello World!'});
});

export { router };
