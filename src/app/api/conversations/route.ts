import { NextRequest } from "next/server";
import { requireAuth } from "@/lib/auth";
import { ok, errorResponse, handleError } from "@/lib/response";
import { prisma } from "@/lib/prisma";

// GET /api/conversations — list all conversations for the current user
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req);

    const conversations = await prisma.conversation.findMany({
      where: {
        OR: [{ buyerId: user.userId }, { sellerId: user.userId }],
      },
      include: {
        buyer: {
          select: { id: true, name: true, avatarUrl: true, phone: true },
        },
        seller: {
          select: { id: true, name: true, avatarUrl: true, phone: true },
        },
        listing: {
          select: { id: true, title: true, priceKgs: true, media: { take: 1 } },
        },
        messages: {
          orderBy: { createdAt: "desc" },
          take: 1,
          select: {
            id: true,
            content: true,
            senderId: true,
            createdAt: true,
            readAt: true,
          },
        },
      },
      orderBy: { lastMessageAt: "desc" },
    });

    // Add unread count for each conversation
    const result = await Promise.all(
      conversations.map(async (conv) => {
        const unreadCount = await prisma.message.count({
          where: {
            conversationId: conv.id,
            senderId: { not: user.userId },
            readAt: null,
          },
        });

        return {
          ...conv,
          lastMessage: conv.messages[0] || null,
          messages: undefined,
          unreadCount,
        };
      })
    );

    return ok(result);
  } catch (error) {
    return handleError(error);
  }
}

// POST /api/conversations — create or get existing conversation
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req);
    const body = await req.json();
    const { sellerId, listingId } = body;

    if (!sellerId) {
      return errorResponse("sellerId is required", 400);
    }

    if (sellerId === user.userId) {
      return errorResponse("Cannot message yourself", 400);
    }

    // Find existing conversation or create new one
    const existing = await prisma.conversation.findFirst({
      where: {
        buyerId: user.userId,
        sellerId,
        listingId: listingId || null,
      },
      include: {
        buyer: {
          select: { id: true, name: true, avatarUrl: true, phone: true },
        },
        seller: {
          select: { id: true, name: true, avatarUrl: true, phone: true },
        },
        listing: {
          select: { id: true, title: true, priceKgs: true, media: { take: 1 } },
        },
      },
    });

    if (existing) {
      return ok(existing);
    }

    const conversation = await prisma.conversation.create({
      data: {
        buyerId: user.userId,
        sellerId,
        listingId: listingId || null,
      },
      include: {
        buyer: {
          select: { id: true, name: true, avatarUrl: true, phone: true },
        },
        seller: {
          select: { id: true, name: true, avatarUrl: true, phone: true },
        },
        listing: {
          select: { id: true, title: true, priceKgs: true, media: { take: 1 } },
        },
      },
    });

    return ok(conversation, 201);
  } catch (error) {
    return handleError(error);
  }
}
