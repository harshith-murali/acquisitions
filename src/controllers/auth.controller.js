import logger from '#configs/logger.js';
import { signupSchema, signinSchema } from '#validators/auth.validator.js';
import { formatValidationErrorResponse } from '#utils/format.js';
import {createUser} from '#services/auth.service.js';
import {jwtToken} from '#utils/jwt.js';
import { cookies } from '#utils/cookies.js';
export const signup = async (req, res, next) => {
  try {
    const validationResult = signupSchema.safeParse(req.body);

    if (!validationResult.success) {
      logger.warn('Validation failed for signup request: %o', validationResult.error);
      const errorResponse = formatValidationErrorResponse(validationResult.error);
      return res.status(400).json(errorResponse);
    }

    const { email, password, name, role } = validationResult.data;

    const user = await createUser({ email, password, name, role });

    const token = jwtToken.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1h' });

    cookies.set(res, "token" , token)

    logger.info('User signed up successfully: %s', email);

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: { id: user.id, email: user.email, name: user.name, role: user.role },
    });
  } catch (err) {
    logger.error('Error in signup controller: %o', err);

    if (err.message === 'User with this email already exists') {
      return res.status(409).json({ success: false, message: err.message });
    }

    next(err);
  }
};

export const signin = async (req, res, next) => {
  try {
    const validationResult = signinSchema.safeParse(req.body);

    if (!validationResult.success) {
      logger.warn('Validation failed for signin request: %o', validationResult.error);
      const errorResponse = formatValidationErrorResponse(validationResult.error);
      return res.status(400).json(errorResponse);
    }

    const { email, password } = validationResult.data;

    const { user, token } = await authService.signin({ email, password });

    logger.info('User signed in successfully: %s', email);

    return res.status(200).json({
      success: true,
      message: 'User signed in successfully',
      data: { id: user.id, email: user.email, name: user.name, role: user.role, token },
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

export const logout = async (req, res, next) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    await authService.logout(userId);

    logger.info('User logged out successfully: %s', userId);

    return res.status(200).json({ success: true, message: 'User logged out successfully' });
  } catch (err) {
    logger.error('Error in logout controller: %o', err);
    next(err);
  }
};