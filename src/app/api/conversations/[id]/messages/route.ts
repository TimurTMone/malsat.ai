import { NextRequest } from "next/server";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";
import { prisma } from "@/lib/prisma";

// GET /api/conversations/[id]/messages — get messages for a conversation
export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const user = requireAuth(req);
    const { id } = await params;

    // Verify user is part of this conversation
    const conversation = await prisma.conversation.findUnique({
      where: { id },
      select: { buyerId: true, sellerId: true },
    });

    if (!conversation) {
      return errorResponse("Conversation not found", 404);
    }

    if (
      conversation.buyerId !== user.userId &&
      conversation.sellerId !== user.userId
    ) {
      return errorResponse("Forbidden", 403);
    }

    const url = new URL(req.url);
    const after = url.searchParams.get("after"); // for polling: only get messages after this ID
    const limit = Math.min(
      parseInt(url.searchParams.get("limit") || "50"),
      100
    );

    const where: any = { conversationId: id };
    if (after) {
      const afterMsg = await prisma.message.findUnique({
        where: { id: after },
        select: { createdAt: true },
      });
      if (afterMsg) {
        where.createdAt = { gt: afterMsg.createdAt };
      }
    }

    const messages = await prisma.message.findMany({
      where,
      include: {
        sender: {
          select: { id: true, name: true, avatarUrl: true },
        },
      },
      orderBy: { createdAt: "asc" },
      take: limit,
    });

    // Mark unread messages as read
    await prisma.message.updateMany({
      where: {
        conversationId: id,
        senderId: { not: user.userId },
        readAt: null,
      },
      data: { readAt: new Date() },
    });

    return ok(messages);
  } catch (error) {
    return handleError(error);
  }
}

// POST /api/conversations/[id]/messages — send a message
export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const user = requireAuth(req);
    const { id } = await params;
    const body = await req.json();
    const { content, mediaUrl } = body;

    if (!content && !mediaUrl) {
      return errorResponse("Message content or media is required", 400);
    }

    // Verify user is part of this conversation
    const conversation = await prisma.conversation.findUnique({
      where: { id },
      select: { buyerId: true, sellerId: true },
    });

    if (!conversation) {
      return errorResponse("Conversation not found", 404);
    }

    if (
      conversation.buyerId !== user.userId &&
      conversation.sellerId !== user.userId
    ) {
      return errorResponse("Forbidden", 403);
    }

    // Create message and update conversation's lastMessageAt
    const [message] = await prisma.$transaction([
      prisma.message.create({
        data: {
          conversationId: id,
          senderId: user.userId,
          content: content || null,
          mediaUrl: mediaUrl || null,
        },
        include: {
          sender: {
            select: { id: true, name: true, avatarUrl: true },
          },
        },
      }),
      prisma.conversation.update({
        where: { id },
        data: { lastMessageAt: new Date() },
      }),
    ]);

    return ok(message, 201);
  } catch (error) {
    return handleError(error);
  }
}
