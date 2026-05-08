import { z } from 'zod';

export const createUserSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(255),
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters').max(255),
  role: z.enum(['user', 'admin']).default('user').optional(),
});

export const updateUserSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters').max(255).optional(),
  email: z.string().email('Invalid email address').optional(),
  role: z.enum(['user', 'admin']).optional(),
});

export const getUserByIdSchema = z.object({
  id: z.coerce.number().positive('User ID must be a positive number'),
});
