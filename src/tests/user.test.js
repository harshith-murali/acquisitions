import { jest } from '@jest/globals';
import request from 'supertest';

let app;
let userService;

beforeAll(async () => {
  jest.unstable_mockModule('#services/user.service.js', () => ({
    createUser: jest.fn(),
    getUserById: jest.fn(),
    getUserByEmail: jest.fn(),
    getAllUsers: jest.fn(),
    updateUser: jest.fn(),
    deleteUser: jest.fn(),
  }));

  app = (await import('../app.js')).default;
  userService = await import('#services/user.service.js');
});

describe('User CRUD API', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /api/users - Create User', () => {
    it('should create a new user successfully', async () => {
      const newUser = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        role: 'user',
      };

      userService.getUserByEmail.mockResolvedValue(null);
      userService.createUser.mockResolvedValue(newUser);

      const res = await request(app).post('/api/users').send({
        name: 'John Doe',
        email: 'john@example.com',
        password: 'securePassword123',
      });

      expect(res.status).toBe(201);
      expect(res.body).toEqual({
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        role: 'user',
      });
    });

    it('should return 409 if email already exists', async () => {
      userService.getUserByEmail.mockResolvedValue({
        id: 1,
        email: 'john@example.com',
      });

      const res = await request(app).post('/api/users').send({
        name: 'John Doe',
        email: 'john@example.com',
        password: 'securePassword123',
      });

      expect(res.status).toBe(409);
      expect(res.body.error).toBe('Email already exists');
    });

    it('should return 400 for invalid email', async () => {
      const res = await request(app).post('/api/users').send({
        name: 'John Doe',
        email: 'invalid-email',
        password: 'securePassword123',
      });

      expect(res.status).toBe(400);
      expect(res.body.error).toContain('Invalid email');
    });

    it('should return 400 for short password', async () => {
      const res = await request(app).post('/api/users').send({
        name: 'John Doe',
        email: 'john@example.com',
        password: 'short',
      });

      expect(res.status).toBe(400);
      expect(res.body.error).toContain('at least 8 characters');
    });
  });

  describe('GET /api/users/:id - Get User by ID', () => {
    it('should return a user by ID', async () => {
      const user = {
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        role: 'user',
        createdAt: new Date(),
      };

      userService.getUserById.mockResolvedValue(user);

      const res = await request(app).get('/api/users/1');

      expect(res.status).toBe(200);
      expect(res.body.id).toBe(1);
      expect(res.body.name).toBe('John Doe');
    });

    it('should return 404 if user not found', async () => {
      userService.getUserById.mockResolvedValue(null);

      const res = await request(app).get('/api/users/999');

      expect(res.status).toBe(404);
      expect(res.body.error).toBe('User not found');
    });

    it('should return 400 for invalid ID', async () => {
      const res = await request(app).get('/api/users/invalid');

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/users - Get All Users', () => {
    it('should return all users', async () => {
      const users = [
        { id: 1, name: 'John', email: 'john@example.com', role: 'user', createdAt: new Date() },
        { id: 2, name: 'Jane', email: 'jane@example.com', role: 'admin', createdAt: new Date() },
      ];

      userService.getAllUsers.mockResolvedValue(users);

      const res = await request(app).get('/api/users');

      expect(res.status).toBe(200);
      expect(res.body).toHaveLength(2);
      expect(res.body[0].name).toBe('John');
      expect(res.body[1].name).toBe('Jane');
    });

    it('should return empty array if no users', async () => {
      userService.getAllUsers.mockResolvedValue([]);

      const res = await request(app).get('/api/users');

      expect(res.status).toBe(200);
      expect(res.body).toEqual([]);
    });
  });

  describe('PUT /api/users/:id - Update User', () => {
    it('should update a user successfully', async () => {
      const updatedUser = {
        id: 1,
        name: 'Jane Doe',
        email: 'jane@example.com',
        role: 'admin',
      };

      userService.getUserById.mockResolvedValue({ id: 1, email: 'john@example.com' });
      userService.getUserByEmail.mockResolvedValue(null);
      userService.updateUser.mockResolvedValue(updatedUser);

      const res = await request(app).put('/api/users/1').send({
        name: 'Jane Doe',
        email: 'jane@example.com',
        role: 'admin',
      });

      expect(res.status).toBe(200);
      expect(res.body.name).toBe('Jane Doe');
      expect(res.body.role).toBe('admin');
    });

    it('should return 404 if user not found', async () => {
      userService.getUserById.mockResolvedValue(null);

      const res = await request(app).put('/api/users/999').send({
        name: 'Jane Doe',
      });

      expect(res.status).toBe(404);
      expect(res.body.error).toBe('User not found');
    });

    it('should return 409 if email already exists', async () => {
      userService.getUserById.mockResolvedValue({ id: 1, email: 'john@example.com' });
      userService.getUserByEmail.mockResolvedValue({ id: 2, email: 'jane@example.com' });

      const res = await request(app).put('/api/users/1').send({
        email: 'jane@example.com',
      });

      expect(res.status).toBe(409);
      expect(res.body.error).toBe('Email already exists');
    });
  });

  describe('DELETE /api/users/:id - Delete User', () => {
    it('should delete a user successfully', async () => {
      const user = { id: 1, name: 'John Doe', email: 'john@example.com' };

      userService.getUserById.mockResolvedValue(user);
      userService.deleteUser.mockResolvedValue(user);

      const res = await request(app).delete('/api/users/1');

      expect(res.status).toBe(200);
      expect(res.body.message).toBe('User deleted successfully');
    });

    it('should return 404 if user not found', async () => {
      userService.getUserById.mockResolvedValue(null);

      const res = await request(app).delete('/api/users/999');

      expect(res.status).toBe(404);
      expect(res.body.error).toBe('User not found');
    });
  });
});
