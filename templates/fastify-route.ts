// templates/fastify-route.ts
// Template for a production-ready Fastify route with TypeScript, Zod validation, and structured logging.

import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';

// 1. Define the schema for input validation using Zod
const bodySchema = z.object({
  name: z.string().min(3),
  tags: z.array(z.string()).optional(),
});

// 2. Infer the TypeScript type from the Zod schema
type BodyType = z.infer<typeof bodySchema>;

// 3. Define the schema for the successful response payload
const replySchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  createdAt: z.date(),
});

export default async function (fastify: FastifyInstance) {
  fastify.post<{ Body: BodyType }>(
    '/api/resource',
    {
      // Attach the schema for validation
      schema: {
        body: bodySchema,
        response: {
          201: replySchema,
        },
      },
      // (Optional) Add middleware for authentication, etc.
      // preHandler: [fastify.authenticate],
    },
    async (request: FastifyRequest<{ Body: BodyType }>, reply: FastifyReply) => {
      try {
        // Structured logging
        fastify.log.info({ body: request.body }, 'Received request to create resource');

        const { name, tags } = request.body;

        // Your business logic here...
        // e.g., const newResource = await someService.create({ name, tags });

        // For demonstration purposes:
        const newResource = {
          id: 'a-uuid-goes-here',
          name,
          createdAt: new Date(),
        };

        return reply.code(201).send(newResource);
      } catch (error) {
        fastify.log.error(error, 'Failed to create resource');
        // Let the default error handler manage the response
        throw error;
      }
    }
  );
}
