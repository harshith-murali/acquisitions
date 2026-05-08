import logger from '#configs/logger.js';
import * as userService from '#services/user.service.js';
import { createUserSchema, updateUserSchema, getUserByIdSchema } from '#validators/user.validator.js';

export const createUser = async (req, res) => {
  try {
    const validated = createUserSchema.parse(req.body);
    const existingUser = await userService.getUserByEmail(validated.email);

    if (existingUser) {
      logger.warn(`User creation failed: Email ${validated.email} already exists`);
      return res.status(409).json({ error: 'Email already exists' });
    }

    const user = await userService.createUser(validated);
    logger.info(`User created successfully: ${user.id}`);
    res.status(201).json({ id: user.id, name: user.name, email: user.email, role: user.role });
  } catch (error) {
    logger.error(`Error creating user: ${error.message}`);
    res.status(400).json({ error: error.message });
  }
};

export const getUserById = async (req, res) => {
  try {
    const { id } = getUserByIdSchema.parse(req.params);
    const user = await userService.getUserById(id);

    if (!user) {
      logger.warn(`User not found: ${id}`);
      return res.status(404).json({ error: 'User not found' });
    }

    logger.info(`User fetched: ${id}`);
    res.status(200).json({ id: user.id, name: user.name, email: user.email, role: user.role, createdAt: user.createdAt });
  } catch (error) {
    logger.error(`Error fetching user: ${error.message}`);
    res.status(400).json({ error: error.message });
  }
};

export const getAllUsers = async (req, res) => {
  try {
    const allUsers = await userService.getAllUsers();
    logger.info(`Fetched all users: ${allUsers.length} users found`);
    res.status(200).json(
      allUsers.map((u) => ({
        id: u.id,
        name: u.name,
        email: u.email,
        role: u.role,
        createdAt: u.createdAt,
      }))
    );
  } catch (error) {
    logger.error(`Error fetching all users: ${error.message}`);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
};

export const updateUser = async (req, res) => {
  try {
    const { id } = getUserByIdSchema.parse(req.params);
    const validated = updateUserSchema.parse(req.body);

    const user = await userService.getUserById(id);
    if (!user) {
      logger.warn(`Update failed: User not found: ${id}`);
      return res.status(404).json({ error: 'User not found' });
    }

    if (validated.email && validated.email !== user.email) {
      const existingUser = await userService.getUserByEmail(validated.email);
      if (existingUser) {
        logger.warn(`Update failed: Email ${validated.email} already exists`);
        return res.status(409).json({ error: 'Email already exists' });
      }
    }

    const updatedUser = await userService.updateUser(id, validated);
    logger.info(`User updated: ${id}`);
    res.status(200).json({ id: updatedUser.id, name: updatedUser.name, email: updatedUser.email, role: updatedUser.role });
  } catch (error) {
    logger.error(`Error updating user: ${error.message}`);
    res.status(400).json({ error: error.message });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const { id } = getUserByIdSchema.parse(req.params);
    const user = await userService.getUserById(id);

    if (!user) {
      logger.warn(`Delete failed: User not found: ${id}`);
      return res.status(404).json({ error: 'User not found' });
    }

    await userService.deleteUser(id);
    logger.info(`User deleted: ${id}`);
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    logger.error(`Error deleting user: ${error.message}`);
    res.status(400).json({ error: error.message });
  }
};
