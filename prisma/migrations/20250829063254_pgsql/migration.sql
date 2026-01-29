-- CreateTable
CREATE TABLE "public"."userinfo" (
    "userId" TEXT NOT NULL,
    "userEmail" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "avatar" TEXT,
    "describeBySelf" TEXT,
    "registrationTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lover" TEXT NOT NULL,
    "score" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "userinfo_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "public"."tasklist" (
    "taskId" TEXT NOT NULL,
    "publisherEmail" TEXT NOT NULL,
    "receiverEmail" TEXT,
    "taskName" TEXT NOT NULL,
    "taskDesc" TEXT,
    "taskImage" TEXT,
    "taskScore" INTEGER NOT NULL DEFAULT 0,
    "taskStatus" TEXT NOT NULL DEFAULT '未开始',
    "creationTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completionTime" TIMESTAMP(3),
    "isApprove" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "tasklist_pkey" PRIMARY KEY ("taskId")
);

-- CreateTable
CREATE TABLE "public"."gift_list" (
    "giftId" TEXT NOT NULL,
    "publisherEmail" TEXT NOT NULL,
    "giftImg" TEXT,
    "giftName" TEXT NOT NULL,
    "giftDetail" TEXT,
    "needScore" INTEGER NOT NULL DEFAULT 0,
    "remained" INTEGER NOT NULL DEFAULT 0,
    "isShow" BOOLEAN NOT NULL DEFAULT true,
    "creationTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "gift_list_pkey" PRIMARY KEY ("giftId")
);

-- CreateTable
CREATE TABLE "public"."whisper_list" (
    "whisperId" TEXT NOT NULL,
    "publisherEmail" TEXT NOT NULL,
    "toUserEmail" TEXT,
    "title" TEXT,
    "content" TEXT NOT NULL,
    "creationTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isRead" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "whisper_list_pkey" PRIMARY KEY ("whisperId")
);

-- CreateTable
CREATE TABLE "public"."favourite_list" (
    "favId" TEXT NOT NULL,
    "userEmail" TEXT NOT NULL,
    "collectionId" TEXT NOT NULL,
    "collectionType" TEXT NOT NULL,
    "creationTime" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "favourite_list_pkey" PRIMARY KEY ("favId")
);

-- CreateIndex
CREATE UNIQUE INDEX "userinfo_userEmail_key" ON "public"."userinfo"("userEmail");

-- CreateIndex
CREATE UNIQUE INDEX "favourite_list_userEmail_collectionId_collectionType_key" ON "public"."favourite_list"("userEmail", "collectionId", "collectionType");

-- AddForeignKey
ALTER TABLE "public"."tasklist" ADD CONSTRAINT "tasklist_publisherEmail_fkey" FOREIGN KEY ("publisherEmail") REFERENCES "public"."userinfo"("userEmail") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."tasklist" ADD CONSTRAINT "tasklist_receiverEmail_fkey" FOREIGN KEY ("receiverEmail") REFERENCES "public"."userinfo"("userEmail") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."gift_list" ADD CONSTRAINT "gift_list_publisherEmail_fkey" FOREIGN KEY ("publisherEmail") REFERENCES "public"."userinfo"("userEmail") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."whisper_list" ADD CONSTRAINT "whisper_list_publisherEmail_fkey" FOREIGN KEY ("publisherEmail") REFERENCES "public"."userinfo"("userEmail") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."whisper_list" ADD CONSTRAINT "whisper_list_toUserEmail_fkey" FOREIGN KEY ("toUserEmail") REFERENCES "public"."userinfo"("userEmail") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."favourite_list" ADD CONSTRAINT "favourite_list_userEmail_fkey" FOREIGN KEY ("userEmail") REFERENCES "public"."userinfo"("userEmail") ON DELETE RESTRICT ON UPDATE CASCADE;
