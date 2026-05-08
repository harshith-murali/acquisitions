export const formatValidationError = (error) => {
  if (!error || !error.issues || !Array.isArray(error.issues)) {
    return 'Validation error';
  }

  return error.issues
    .map((issue) => {
      const path = issue.path.length > 0 ? issue.path.join('.') : 'root';
      return `${path}: ${issue.message}`;
    })
    .join(', ');
};

export const formatValidationErrors = (error) => {
  if (!error || !error.issues || !Array.isArray(error.issues)) {
    return { errors: { root: ['Validation error'] } };
  }

  const errors = {};

  error.issues.forEach((issue) => {
    const path = issue.path.length > 0 ? issue.path.join('.') : 'root';
    if (!errors[path]) {
      errors[path] = [];
    }
    errors[path].push(issue.message);
  });

  return { errors };
};

export const formatValidationErrorResponse = (error) => {
  if (!error || !error.issues || !Array.isArray(error.issues)) {
    return {
      success: false,
      message: 'Validation failed',
      errors: { root: ['Validation error'] },
    };
  }

  const errors = {};

  error.issues.forEach((issue) => {
    const path = issue.path.length > 0 ? issue.path.join('.') : 'root';
    if (!errors[path]) {
      errors[path] = [];
    }
    errors[path].push(issue.message);
  });

  return {
    success: false,
    message: 'Validation failed',
    errors,
  };
};