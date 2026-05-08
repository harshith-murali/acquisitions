import logger from '#configs/logger.js';
import bcrypt from 'bcrypt';
import { db } from '#configs/db.js';
import { users } from '#models/user.model.js';
import { eq } from 'drizzle-orm';

export const hashPassword = async password => {
  try {
    return await bcrypt.hash(password, 10);
  } catch (err) {
    logger.error('Error hashing password: %o', err);
    throw new Error('Error hashing password');
  }
};

export const createUser = async ({
  email,
  password,
  name,
  role,
}) => {
  try {
    const existingUser = await db
      .select()
      .from(users)
      .where(eq(users.email, email))
      .limit(1);

    if (existingUser.length > 0) {
      logger.warn('User already exists: %s', email);
      throw new Error('User already exists');
    }

    const hashedPassword = await hashPassword(password);

    const newUser = await db
      .insert(users)
      .values({
        email,
        password: hashedPassword,
        name,
        role,
      })
      .returning();
      logger.info('User created successfully: %s', email);
    return newUser[0];
  } catch (err) {
    logger.error('Error creating user: %o', err);
    throw err;
  }
};