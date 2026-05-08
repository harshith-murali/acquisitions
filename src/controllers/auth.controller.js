import logger from '#configs/logger.js';
import { signupSchema, signinSchema } from '#validators/auth.validator.js';
import { formatValidationErrorResponse } from '#utils/format.js';
import { createUser, authenticateUser } from '#services/auth.service.js';
import { jwtToken } from '#utils/jwt.js';
import { cookies } from '#utils/cookies.js';

const getSafeUserPayload = user => ({
  id: user.id,
  email: user.email,
  name: user.name,
  role: user.role,
});

export const signup = async (req, res, next) => {
  try {
    const validationResult = signupSchema.safeParse(req.body);

    if (!validationResult.success) {
      logger.warn(
        'Validation failed for signup request: %o',
        validationResult.error
      );
      const errorResponse = formatValidationErrorResponse(validationResult.error);
      return res.status(400).json(errorResponse);
    }

    const { email, password, name, role } = validationResult.data;
    const user = await createUser({ email, password, name, role });

    const token = jwtToken.sign({
      id: user.id,
      email: user.email,
      role: user.role,
    });

    cookies.set(res, 'token', token);

    logger.info('User signed up successfully: %s', email);

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: getSafeUserPayload(user),
    });
  } catch (err) {
    logger.error('Error in signup controller: %o', err);

    if (err.message === 'User already exists') {
      return res.status(409).json({ success: false, message: err.message });
    }

    next(err);
  }
};

export const signin = async (req, res, next) => {
  try {
    const validationResult = signinSchema.safeParse(req.body);

    if (!validationResult.success) {
      logger.warn(
        'Validation failed for signin request: %o',
        validationResult.error
      );
      const errorResponse = formatValidationErrorResponse(validationResult.error);
      return res.status(400).json(errorResponse);
    }

    const { email, password } = validationResult.data;
    const user = await authenticateUser({ email, password });

    const token = jwtToken.sign({
      id: user.id,
      email: user.email,
      role: user.role,
    });

    cookies.set(res, 'token', token);

    logger.info('User signed in successfully: %s', email);

    return res.status(200).json({
      success: true,
      message: 'User signed in successfully',
      data: getSafeUserPayload(user),
    });
  } catch (err) {
    logger.error('Error in signin controller: %o', err);

    if (err.message === 'Invalid credentials') {
      return res.status(401).json({ success: false, message: err.message });
    }

    if (err.message === 'User not found') {
      return res.status(404).json({ success: false, message: err.message });
    }

    next(err);
  }
};

export const signout = async (req, res, next) => {
  try {
    const token = cookies.get(req, 'token');

    if (!token) {
      logger.warn('Unauthorized signout attempt');
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    cookies.clear(res, 'token');
    logger.info('User signed out successfully');

    return res
      .status(200)
      .json({ success: true, message: 'User signed out successfully' });
  } catch (err) {
    logger.error('Error in signout controller: %o', err);
    next(err);
  }
};

export const logout = signout;
