import aj from '#configs/arcjet.js';
import logger from '#configs/logger.js';

const securityMiddleware = async (req, res, next) => {
  try {
    const role = req.user?.role || 'guest';

    let requestedTokens;

    switch (role) {
      case 'admin':
        requestedTokens = 1;
        break;

      case 'user':
        requestedTokens = 3;
        break;

      default:
        requestedTokens = 5;
    }

    const decision = await aj.protect(req, {
      requested: requestedTokens,
    });

    if (decision.isDenied()) {
      if (decision.reason.isRateLimit()) {
        logger.warn('Rate limit exceeded: %s', req.ip);

        return res.status(429).json({
          success: false,
          message: 'Too many requests',
        });
      }

      if (decision.reason.isBot()) {
        logger.warn('Bot detected: %s', req.ip);

        if (process.env.NODE_ENV !== 'development') {
          return res.status(403).json({
            success: false,
            message: 'Bot access denied',
          });
        }
      }

      if (process.env.NODE_ENV !== 'development') {
        return res.status(403).json({
          success: false,
          message: 'Access denied',
        });
      }
    }

    next();
  } catch (err) {
    logger.error('Security middleware error: %o', err);

    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
};

export default securityMiddleware;