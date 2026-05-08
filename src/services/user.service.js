import { db } from '#configs/db.js';
import { users } from '#models/user.model.js';
import { eq } from 'drizzle-orm';
import bcrypt from 'bcrypt';

export const createUser = async (userData) => {
  const { name, email, password, role = 'user' } = userData;

  const hashedPassword = await bcrypt.hash(password, 10);

  const result = await db
    .insert(users)
    .values({
      name,
      email,
      password: hashedPassword,
      role,
    })
    .returning();

  return result[0];
};

export const getUserById = async (id) => {
  const user = await db.select().from(users).where(eq(users.id, id));
  return user[0] || null;
};

export const getUserByEmail = async (email) => {
  const user = await db.select().from(users).where(eq(users.email, email));
  return user[0] || null;
};

export const getAllUsers = async () => {
  const allUsers = await db.select().from(users);
  return allUsers;
};

export const updateUser = async (id, userData) => {
  const { name, email, role } = userData;

  const updateData = {};
  if (name) updateData.name = name;
  if (email) updateData.email = email;
  if (role) updateData.role = role;
  updateData.updatedAt = new Date();

  const result = await db.update(users).set(updateData).where(eq(users.id, id)).returning();

  return result[0] || null;
};

export const deleteUser = async (id) => {
  const result = await db.delete(users).where(eq(users.id, id)).returning();
  return result[0] || null;
};
