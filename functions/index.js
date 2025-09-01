const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {onSchedule} = require("firebase-functions/v2/scheduler");

admin.initializeApp();

async function studyReminder(context) {
    const db = admin.firestore();
    const messaging = admin.messaging();

    // 1. 어제 같은 시간대 계산 (24시간 전)
    const now = new Date();
    const yesterday = new Date(now.getTime() - (24 * 60 * 60 * 1000));
    const targetHourStart = new Date(yesterday.setMinutes(0, 0, 0));
    const targetHourEnd = new Date(yesterday.setMinutes(59, 59, 999));

    console.log(`알림 보낼 사용자 검색 시간대: ${targetHourStart} ~ ${targetHourEnd}`);

    // 2. 알림 보낼 사용자 쿼리
    const usersSnapshot = await db.collection("Users")
      .where("fcmPermission", "==", true)
      .where("lastStudyDate", ">=", targetHourStart)
      .where("lastStudyDate", "<=", targetHourEnd)
      .get();

    // 대상 사용자가 없으면 함수를 종료합니다.
    if (usersSnapshot.empty) {
        console.log("알림을 보낼 사용자가 없습니다.");
        return null;
    }

    const tokens = [];
    usersSnapshot.forEach((doc) => {
        const fcmToken = doc.data().fcmToken;
        if (fcmToken) {
            tokens.push(fcmToken);
        }
    });

    // 토큰이 하나 이상 있을 경우에만 메시지를 전송합니다.
    if (tokens.length > 0) {
        console.log(`${tokens.length}명의 사용자에게 알림을 전송합니다.`);

        // 3. 알림 메시지 정의
        const message = {
            notification: {
                title: "🍇 Keep the momentum going!",
                body: "Let's continue the progress you made yesterday. Time to start learning now!",
            },
            tokens: tokens,
        };

        // 4. FCM 알림 전송
        try {
            const response = await messaging.sendEachForMulticast(message);
            console.log(`알림 전송 완료: ${response.successCount}건 성공, ${response.failureCount}건 실패`);

            // 전송 실패한 토큰 정리 (선택 사항)
            if (response.failureCount > 0) {
                const failedTokens = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        failedTokens.push(tokens[idx]);
                        console.error(`실패 토큰 [${tokens[idx]}]: ${resp.error.message}`);
                        // 여기서 'messaging/registration-token-not-registered' 에러 등을 확인하여
                        // 데이터베이스에서 해당 토큰을 삭제하는 로직을 추가할 수 있습니다.
                    }
                });
                console.log(`실패한 토큰 목록: ${failedTokens}`);
            }
        } catch (error) {
          console.error("알림 전송 중 에러 발생:", error);
        }
    } else {
        console.log("유효한 FCM 토큰을 가진 사용자가 없습니다.");
    }

    return null;
}

exports.onStudyReminder = onSchedule({
    schedule: "0 * * * *",
    timezone: "Asia/Seoul",
}, studyReminder);