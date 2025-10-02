const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require('D:\\keys\\podo_words\\podo-words-firebase-adminsdk-fbsvc-bb4b69e29e.json');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs'); // 파일 시스템 접근을 위한 'fs' 모듈
const path = require('path'); // 파일 경로 관리를 위한 'path' 모듈
const { exec } = require('child_process'); // 외부 명령 실행을 위한 모듈
const util = require('util'); // exec를 Promise로 바꾸기 위함
const os = require('os'); // 임시 폴더 경로를 얻기 위함

// exec 함수를 Promise 기반으로 변환하여 async/await와 함께 사용
const promisifiedExec = util.promisify(exec);

// 테스트 유저 아이디: QTAObalhO6TQF67tdJE6AIV74gn1

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'podo-words',
  storageBucket: 'podo-words.firebasestorage.app'
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

async function notificationTest() {
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
                title: "🍇 어제의 열공, 오늘도 이어갈 시간!",
                body: "어제의 열정을 오늘도 이어가요! 지금 바로 학습을 시작해 보세요.",
            },
            tokens: tokens,
        };

        // 4. FCM 알림 전송
        try {

            const response = await messaging.sendEachForMulticast(message);
            console.log(`알림 전송 완료: ${response.successCount}건 성공, ${response.failureCount}건 실패`);

            // 전송 실패한 토큰이 있다면 정리합니다.
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

const dataToMigrate = [

        // 0
            {
              'title' : ['food'],
              'front' : ['밥','국','반찬','고기','김치','만두','김','두부','생선','해산물','면','빵','떡볶이','김밥','비빔밥','햄버거','피자','한식','양식','중식','일식'],
              'back' : ['rice/meal','soup','side dish','meat','kimchi','dumplings','dried seaweed','tofu','fish','seafood','noodles','bread','tteok-bokki','gimbap','bibimbap','hamburger','pizza','Korean food','Western food','Chinese food','Japanese food'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','-','떡보끼','김빱','비빔빱','-','-','-','-','-','-']
            },
        // 1
            {
              'title' : ['dessert'],
              'front' : ['과일','음료','초콜릿','케이크','팥빙수','얼음','아이스크림','떡','사탕','과자'],
              'back' : ['fruit','beverage','chocolate','cake','Korean shaved ice','ice','ice cream','rice cake','candy','snacks'],
              'pronunciation' : ['-','음뇨','-','-','팓삥수','어름','-','-','-','-']
            },
        // 2
            {
              'title' : ['fruit'],
              'front' : ['사과','딸기','포도','수박','바나나','배','귤','오렌지','블루베리','복숭아'],
              'back' : ['apple','strawberry','grape','watermelon','banana','pear','tangerine','orange','blueberry','peach'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','복쑹아']
            },
        // 3
            {
              'title' : ['vegetable'],
              'front' : ['당근','감자','고구마','양파','오이','버섯','호박','무','고추','마늘','토마토','옥수수','콩','파','상추','콩나물','양배추','시금치'],
              'back' : ['carrot','potato','sweet potato','onion','cucumber','mushroom','pumpkin','radish','chili','garlic','tomato','corn','bean','green onion','lettuce','bean sprouts','cabbage','spinach'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','옥쑤수','-','-','-','-','-','-']
            },
        // 4
            {
              'title' : ['seasoning'],
              'front' : ['설탕','소금','간장','식초','후추','식용유','고추장','고춧가루','된장','향신료','꿀'],
              'back' : ['sugar','salt','soy sauce','vinegar','pepper','cooking oil','red pepper paste','red pepper powder','soybean paste','spice','honey'],
              'pronunciation' : ['-','-','-','-','-','시굥뉴','-','고춛까루','-','향신뇨','-']
            },
        // 5
            {
              'title' : ['cooking'],
              'front' : ['굽다','끓이다','볶다','튀기다','찌다','자르다','넣다','빼다','섞다','뿌리다','맛을 보다'],
              'back' : ['roast','boil','stir-fry','fry','steam','cut','put in','take out','mix','spray','taste'],
              'pronunciation' : ['굽따','끄리다','복따','-','-','-','너타','-','석따','-','마슬보다']
            },
        // 6
            {
              'title' : ['taste'],
              'front' : ['맛있다','맛없다','달다','쓰다','맵다','짜다','싱겁다','시다','신선하다','상하다','익다','썩다'],
              'back' : ['delicious','not delicious','sweet','bitter','spicy','salty','bland','sour','fresh','go bad','ripen','decay'],
              'pronunciation' : ['마싣따','마덥따','-','-','맵따','-','싱겁따','-','-','-','익따','썩따']
            },
        // 7
            {
              'title' : ['drink'],
              'front' : ['물','커피','우유','주스','콜라','차','술','맥주','소주','막걸리','와인'],
              'back' : ['water','coffee','milk','juice','Coke','tea','alcohol','beer','soju','makgeolli/rice wine','wine'],
              'pronunciation' : ['-','-','-','주쓰','-','-','-','맥쭈','-','막껄리','-']
            },
        // 8
            {
              'title' : ['house space'],
              'front' : ['방','안방','옷방','거실','주방','화장실','창고','계단','지하실','옥상','벽','천장'],
              'back' : ['room','main room','dressing room','living room','kitchen','bathroom','warehouse','stairs','basement','roof','wall','ceiling'],
              'pronunciation' : ['-','안빵','옫빵','-','-','-','-','-','-','옥쌍','-','-']
            },
        // 9
            {
              'title' : ['house things'],
              'front' : ['책상','의자','침대','이불','베개','옷장','옷걸이','소파','식탁','신발장','창문','문','불','쓰레기통','달력','나무','꽃'],
              'back' : ['desk','chair','bed','blanket','pillow','closet','hanger','sofa','table','shoe rack','window','door','light','trash can','calendar','tree','flower'],
              'pronunciation' : ['책쌍','-','-','-','-','옫짱','옫꺼리','-','-','신발짱','-','-','-','-','-','-','꼳']
            },
        // 10
            {
              'title' : ['electronics'],
              'front' : ['휴대폰','컴퓨터','노트북','텔레비전','냉장고','세탁기','청소기','선풍기','에어컨','전자레인지','다리미','전기','충전'],
              'back' : ['cell phone','computer','laptop','television','refrigerator','washing machine','vacuum cleaner','electric fan','air conditioner','microwave','iron','electricity','charging'],
              'pronunciation' : ['-','-','-','-','-','세탁끼','-','-','-','-','-','-','-']
            },
        // 11
            {
              'title' : ['belongings'],
              'front' : ['지갑','열쇠','가방','짐','신분증','여권','화장품','향수','우산','책','선물','표'],
              'back' : ['wallet','key','bag','luggage','ID card','passport','cosmetics','perfume','umbrella','book','present','ticket'],
              'pronunciation' : ['-','열쐬','-','-','신분쯩','여꿘','-','-','-','-','-','-']
            },
        // 12
            {
              'title' : ['housework'],
              'front' : ['정리하다','청소하다','빨래하다','장을 보다','쓰레기를 버리다','설거지하다','이사하다','고치다','만들다'],
              'back' : ['tidy up','clean up','laundry','grocery shopping','throw away','wash dishes','move','fix','make'],
              'pronunciation' : ['정니하다','-','-','-','-','-','-','-','-']
            },
        // 13
            {
              'title' : ['restroom'],
              'front' : ['세면대','변기','욕조','샤워기','거울','칫솔','치약','면도기','비누','빗','수건','휴지','씻다','양치하다/이를 닦다','세수하다'],
              'back' : ['sink','toilet','bathtub','shower','mirror','toothbrush','toothpaste','razor','soap','comb','towel','toilet paper','wash','brush teeth','wash face'],
              'pronunciation' : ['-','-','-','-','-','칟쏠','-','-','-','-','-','-','씯따','이를닥따','-']
            },
        // 14
            {
              'title' : ['kitchen'],
              'front' : ['숟가락','젓가락','포크','컵','접시','그릇','냄비','도마','칼','국자','가위','앞치마'],
              'back' : ['spoon','chopsticks','fork','cup','plate','bowl','pot','cutting board','knife','ladle','scissors','apron'],
              'pronunciation' : ['숟까락','젇까락','-','-','접씨','-','-','-','-','국짜','-','-']
            },
        // 15
            {
              'title' : ['place1'],
              'front' : ['집','학교','도서관','회사','식당','영화관','서점','경찰서','소방서','병원','약국','공항','호텔','커피숍','공원','마트','시장'],
              'back' : ['house','school','library','company','restaurant','movie theater','bookstore','police station','fire station','hospital','drugstore','airport','hotel','cafe','park','supermarket','market'],
              'pronunciation' : ['-','학꾜','-','-','식땅','-','-','경찰써','-','-','약꾹','-','-','-','-','-','-']
            },
        // 16
            {
              'title' : ['place2'],
              'front' : ['교회','미용실','대사관','헬스장','주차장','주유소','버스정류장','지하철역','백화점','동물원','편의점','부동산','길','가게','세탁소','은행','주소'],
              'back' : ['church','hair salon','embassy','fitness center','parking lot','gas station','bus stop','subway station','department store','zoo','convenience store','real estate agency','road','shop','laundry','bank','address'],
              'pronunciation' : ['-','-','-','헬쓰장','-','-','버스정뉴장','지하철력','배콰점','동무뤈','펴니점','-','-','-','세탁쏘','-','-']
            },
        // 17
            {
              'title' : ['school'],
              'front' : ['초등학교','중학교','고등학교','대학교','대학원','입학','졸업','수업','숙제','시험','문제','축제','방학','교실','기숙사','유학','학비','가르치다','배우다','공부하다','지각하다','단어','문장','발음'],
              'back' : ['elementary school','middle school','high school','university','graduate school','entering the school','graduation','lesson','homework','examination','question','festival','school vacation','classroom','dormitory','studying abroad','tuition','teach','learn','study','be late','word','sentence','pronunciation'],
              'pronunciation' : ['초등학꾜','중학꾜','고등학꾜','대학꾜','대하권','이팍','조럽','-','숙쩨','-','-','축쩨','-','-','기숙싸','-','학삐','-','-','-','지가카다','다너','-','바름']
            },
        // 18
            {
              'title' : ['company'],
              'front' : ['출근','퇴근','야근','점심시간','사무실','출장','휴가','회사동료','회의','발표','계약','월급','연봉','이메일','사장','직원','전화하다','전화받다','돈을 벌다','취직하다','승진하다','퇴사하다','은퇴하다'],
              'back' : ['go to work','leave work','work late','lunch time','office','business trip','vacation','colleague','meeting','presentation','contract','salary','annual salary','E-mail','boss','employee','make a call','answer the phone','earn money','get a job','be promoted','quit the job','retire'],
              'pronunciation' : ['-','-','-','-','-','출짱','-','회사동뇨','-','-','-','-','-','-','-','지권','-','전화받따','도늘벌다','취지카다','-','-','-']
            },
        // 19
            {
              'title' : ['family'],
              'front' : ['엄마=어머니','아빠=아버지','부모님','남동생','여동생','형','오빠','누나','언니','형제','할아버지','할머니','삼촌','고모','이모','사촌','남편','아내','아들','딸','장인어른','장모님','조카'],
              'back' : ['mom=mother','dad=father','parents','younger brother','younger sister','older brother(for male)','older brother(for female)','older sister(for male)','older sister(for female)','siblings','grandfather','grandmother','uncle','aunt(father side)','aunt(mother side)','cousin','husband','wife','son','daughter','father-in-law','mother-in-law','nephew'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','하라버지','-','-','-','-','-','-','-','-','-','장이너른','-','-']
            },
        // 20
            {
              'title' : ['people'],
              'front' : ['가족','친구','남자','여자','여자친구','남자친구','아기','아이=어린이','어른','아는 사람','이웃','아저씨','아줌마','쌍둥이','손님','동양인','서양인'],
              'back' : ['family','friend','man','woman','girlfriend','boyfriend','baby','child','adult','acquaintance','neighbor','middle-aged man','middle-aged woman','twins','quest','Asians','Westerners'],
              'pronunciation' : ['-','-','-','-','-','-','-','어리니','-','-','-','-','-','-','-','-','-']
            },
        // 21
            {
              'title' : ['people\ndescription'],
              'front' : ['어리다','나이가 많다','태어나다','자라다','결혼하다','사귀다','헤어지다','피곤하다','배고프다','배부르다','졸리다=잠이 오다','졸다','아이를 낳다','아이를 키우다','죽다','돌아가시다'],
              'back' : ['young','old','be born','grow up','get married','going out','break up','tired','hungry','full','sleepy','doze off','give birth','raise a child','die','pass away'],
              'pronunciation' : ['-','나이가만타','-','-','-','-','-','-','-','-','자미오다','-','아이를나타','-','죽따','도라가시다']
            },
        // 22
            {
              'title' : ['body1'],
              'front' : ['머리','얼굴','이마','눈','코','입','이','귀','목','어깨','팔','손','손가락','발','발가락','가슴','배','등','다리'],
              'back' : ['head','face','forehead','eyes','nose','mouth','tooth','ears','neck','shoulder','arm','hand','finger','foot','toe','chest','belly','back','leg'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','-','손까락','-','발까락','-','-','-','-']
            },
        // 23
            {
              'title' : ['body2'],
              'front' : ['수염','눈썹','혀','목구멍','입술','볼','턱','팔꿈치','손목','손등','손바닥','손톱','발목','발등','발바닥','발톱','허리','엉덩이','무릎'],
              'back' : ['beard','eyebrows','tongue','throat','lips','cheek','chin','elbow','wrist','back of hand','palm','nail','ankle','top of the foot','sole','toenail','waist','butt','knee'],
              'pronunciation' : ['-','-','-','목꾸멍','입쑬','-','-','-','-','손뜽','손빠닥','-','-','발뜽','발빠닥','-','-','-','-']
            },
        // 24
            {
              'title' : ['appearance'],
              'front' : ['뚱뚱하다','날씬하다','말랐다','멋있다','잘생기다','못생기다','예쁘다','귀엽다','키가 크다','키가 작다','힘이 세다','약하다','머리가 길다','머리가 짧다','살이 찌다','살을 빼다','살이 빠지다','평범하다'],
              'back' : ['fat','slim','skinny','good-looking','handsome','ugly','pretty','cute','tall','short','strong','weak','long hair','short hair','gain weight','on a diet','lose weight','normal'],
              'pronunciation' : ['-','-','-','머싣따','잘쌩기다','몯쌩기다','-','귀엽따','-','키가작따','히미세다','야카다','-','머리가짤따','사리찌다','사를빼다','사리빠지다','-']
            },
        // 25
            {
              'title' : ['personality'],
              'front' : ['성격이 좋다','착하다','부지런하다','게으르다','친절하다','활발하다','조용하다','겸손하다','거만하다','이기적이다','인내심이 있다','욕심이 많다','자신감이 있다','솔직하다'],
              'back' : ['have a good personality','nice','diligent','lazy','kind','outgoing','quiet','humble','arrogant','selfish','patient','greedy','confident','honest'],
              'pronunciation' : ['성껴기조타','차카다','-','-','-','-','-','-','-','-','인내시미읻따','욕시미만타','자신가미읻따','솔찌카다']
            },
        // 26
            {
              'title' : ['job'],
              'front' : ['선생님','학생','회사원','경찰','소방관','요리사','의사','간호사','공무원','변호사','배우','가수','운동선수','아르바이트','군인','사진작가','사업가','대통령'],
              'back' : ['teacher','student','office worker','police','firefighter','chef','doctor','nurse','officer','lawyer','actor','singer','athlete','part-timer','soldier','photographer','businessman','president'],
              'pronunciation' : ['-','학쌩','-','-','-','-','-','-','-','-','-','-','-','-','구닌','사진작까','사업까','대통녕']
            },
        // 27
            {
              'title' : ['hobby'],
              'front' : ['드라마','자막','요리','운동','여행','영화','쇼핑','게임','외국어','낚시','등산','책을 읽다','음악을 듣다','피아노를 치다','자전거를 타다','공연을 보다','춤을 추다','노래를 부르다','사진을 찍다','그림을 그리다'],
              'back' : ['drama','subtitles','cooking','workout','travel','movie','shopping','game','foreign language','fishing','hiking','read a book','listen to music','play the piano','ride a bike','watch a performance','dance','sing a song','take a photo','draw a picture'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','외구거','낙씨','-','채글익따','으마글듣따','-','-','공여늘보다','추믈추다','-','사지늘찍따','그리믈그리다']
            },
        // 28
            {
              'title' : ['travel'],
              'front' : ['산','바다','강','섬','도시','시골','숲','호수','하늘','예약하다','물가가 싸다','음식이 입에 맞다','경치가 좋다','공기가 좋다'],
              'back' : ['mountain','sea','river','island','city','countryside','forest','lake','sky','make a reservation','prices are cheap','food suits taste','nice view','fresh air'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','예야카다','물까가싸다','음시기이베맏따','경치가조타','공기가조타']
            },
        // 29
            {
              'title' : ['schedule'],
              'front' : ['시작하다','끝나다','준비하다','늦다','연기하다','취소하다','계획을 세우다','바꾸다','결정하다','고민하다','미루다','결심하다','포기하다','그만두다','계속하다','약속하다'],
              'back' : ['start','end','prepare','late','postpone','cancel','make a plan','change','decide','consider','put off','make mind up','give up','stop','continue','promise'],
              'pronunciation' : ['시자카다','끈나다','-','늗따','-','-','계회글세우다','-','결쩡하다','-','-','-','-','-','계소카다','약쏘카다']
            },
        // 30
            {
              'title' : ['country'],
              'front' : ['한국','미국','일본','중국','필리핀','베트남','태국','인도','호주','영국','독일','프랑스','스페인','러시아','브라질'],
              'back' : ['Korea','the United States','Japan','China','philippines','Vietnam','Thailand','India','Australia','the United kingdom','Germany','France','Spain','Russia','Brazil'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','도길','-','-','-','-']
            },
        // 31
            {
              'title' : ['vehicle'],
              'front' : ['차','버스','택시','비행기','자전거','기차','지하철','오토바이','배'],
              'back' : ['car','bus','taxi','airplane','bicycle','train','subway','bike','ship'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-']
            },
        // 32
            {
              'title' : ['movement'],
              'front' : ['가다','오다','걷다','뛰다','타다','내리다','다니다','들르다','마중나가다','배웅하다','환승하다','돌다','옮기다','올라가다/올라오다','내려가다/내려오다','건너가다/건너오다','지나가다/지나오다','들어가다/들어오다','나가다/나오다','돌아가다/돌아오다','가져가다/가져오다','데려가다/데려오다','따라가다/따라오다'],
              'back' : ['go','come','walk','run','ride','get off','go to ~ regularly','stop by','go pick someone up','see someone off','transfer','turn','move','go up/come up','go down/come down','go over/come over','pass by','enter/come in','go out/come out','go back/come back','take/bring','take/bring(people)','follow'],
              'pronunciation' : ['-','-','걷따','-','-','-','-','-','-','-','-','-','옴기다','-','-','-','-','드러가다/드러오다','-','도라가다/도라오다','-','-','-']
            },
        // 33
            {
              'title' : ['shopping'],
              'front' : ['사다','팔다','싸다','비싸다','계산하다','할인','신용카드','현금','돈','잔돈','무료/공짜','환전','교환','환불','일시불','할부','영수증','깎다','매진'],
              'back' : ['buy','sell','cheap','expensive','pay','discount','credit card','cash','money','change','free','currency exchange','exchange','refund','payment in full','monthly installment','receipt','price down','sold out'],
              'pronunciation' : ['-','-','-','-','-','하린','시뇽카드','-','-','-','-','-','-','-','-','-','-','깍따','-']
            },
        // 34
            {
              'title' : ['clothes'],
              'front' : ['옷','바지','반바지','치마','셔츠','티셔츠','원피스','수영복','속옷','운동복','청바지','스웨터','코트','정장','한복','교복'],
              'back' : ['clothes','pants','shorts','skirt','shirts','T-shirt','dress','swimming suit','underwear','sportswear','jeans','sweater','coat','suit','Hanbok','school uniform'],
              'pronunciation' : ['옫','-','-','-','-','-','-','-','소곧','-','-','-','-','-','-','-']
            },
        // 35
            {
              'title' : ['accessory'],
              'front' : ['신발','운동화','양말','스타킹','슬리퍼','구두','모자','안경','선글라스','마스크','귀걸이','목걸이','넥타이','시계','팔찌','반지','장갑','벨트'],
              'back' : ['shoes','sneakers','socks','stockings','slippers','dress shoes','hat/cap','glasses','sunglasses','mask','earrings','necklace','tie','watch/clock','bracelet','ring','gloves','belt'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','썬글라스','-','귀거리','목거리','-','-','-','-','-','-']
            },
        // 36
            {
              'title' : ['location'],
              'front' : ['앞','뒤','왼쪽','오른쪽','옆','안','밖','위','아래','가운데','가깝다','멀다','처음','중간','마지막','근처','건너편'],
              'back' : ['front','behind','left','right','next to','inside','outside','above','below','center','close','far','first','middle','last','near','opposite side'],
              'pronunciation' : ['압','-','-','-','엽','-','-','-','-','-','가깝따','-','-','-','-','-','-']
            },
        // 37
            {
              'title' : ['shape'],
              'front' : ['크다','작다','길다','짧다','두껍다','얇다','깊다','얕다','넓다','좁다','둥글다','네모','세모','별','하트','줄무늬','체크'],
              'back' : ['big','small','long','short','thick','thin','deep','shallow','large','narrow','round','square','triangle','star','heart','stripe','plaid'],
              'pronunciation' : ['-','작따','-','짤따','두껍따','얄따','깁따','얃따','널따','좁따','-','-','-','-','-','줄무니','-']
            },
        // 38
            {
              'title' : ['sports'],
              'front' : ['야구','축구','농구','배구','탁구','스키','골프','수영','요가','태권도','테니스','스케이트'],
              'back' : ['baseball','soccer','basketball','volleyball','table tennis','ski','golf','swimming','yoga','Taekwondo','tennis','skating'],
              'pronunciation' : ['-','축꾸','-','-','탁꾸','-','-','-','-','태꿘도','-','-']
            },
        // 39
            {
              'title' : ['time1'],
              'front' : ['아침','점심','저녁','오전','오후','낮','밤','전','후','지금','나중에','곧','빨리','천천히'],
              'back' : ['morning','afternoon','evening','a.m.','p.m.','daytime','night','before','after','now','later','soon','quickly','slowly'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','-','-','-']
            },
        // 40
            {
              'title' : ['time2'],
              'front' : ['저번','이번','다음','일찍','늦게','잠깐','오래','아직','벌써','방금','미리'],
              'back' : ['last time','this time','next time','early','late','for a moment','long time','yet','already','just before','in advance'],
              'pronunciation' : ['-','-','-','-','늗께','-','-','-','-','-','-']
            },
        // 41
            {
              'title' : ['day'],
              'front' : ['어제','오늘','내일','월','일','작년','올해','내년','월요일','화요일','수요일','목요일','금요일','토요일','일요일','평일','주말','매일','매주','매달','생일'],
              'back' : ['yesterday','today','tomorrow','month','day','last year','this year','next year','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday','weekday','weekend','everyday','every week','every month','birthday'],
              'pronunciation' : ['-','-','-','-','-','장년','-','-','워료일','-','-','모교일','그묘일','-','이료일','-','-','-','-','-','-']
            },
        // 42
            {
              'title' : ['color'],
              'front' : ['흰색=하얀색','검은색=까만색','빨간색','주황색','노란색','초록색=녹색','파란색','남색','보라색','회색','하늘색','분홍색','갈색','밝은색','어두운색','연한색','진한색'],
              'back' : ['white','black','red','orange','yellow','green','blue','indigo','purple','gray','sky blue','pink','brown','bright color','dark color','light color','deep color'],
              'pronunciation' : ['힌색','거믄색','-','-','-','초록쌕','-','-','-','-','하늘쌕','-','갈쌕','발근색','-','-','-']
            },
        // 43
            {
              'title' : ['weather'],
              'front' : ['봄','여름','가을','겨울','비가 오다','눈이 오다','덥다','춥다','따뜻하다','시원하다','쌀쌀하다','맑다','흐리다','습하다','건조하다','해','구름','하늘','기온','소나기','장마','태풍','바람이 불다','안개가 끼다'],
              'back' : ['spring','summer','fall','winter','rain','snow','hot','cold','warm','cool','chilly','clear','cloudy','humid','dry','sun','cloud','sky','temperature','shower','rainy season','typhoon','wind blows','foggy'],
              'pronunciation' : ['-','-','-','-','-','누니오다','덥따','춥따','따뜨타다','-','-','막따','-','스파다','-','-','-','-','-','-','-','-','바라미불다','-']
            },
        // 44
            {
              'title' : ['animal1'],
              'front' : ['개/강아지','고양이','새','물고기','사자','호랑이','곰','소','돼지','닭','토끼','코끼리','원숭이','양','말','뱀'],
              'back' : ['dog','cat','bird','fish','lion','tiger','bear','cow','pig','chicken','rabbit','elephant','monkey','sheep','horse','snake'],
              'pronunciation' : ['-','-','-','물꼬기','-','-','-','-','-','닥','-','-','-','-','-','-']
            },
        // 45
            {
              'title' : ['animal2'],
              'front' : ['기린','사슴','오리','여우','악어','개구리','거북이','쥐','나비','벌','벌레','모기','꼬리','털','날개'],
              'back' : ['giraffe','deer','duck','fox','crocodile','frog','turtle','rat','butterfly','bee','worm','mosquito','tail','fur','wings'],
              'pronunciation' : ['-','-','-','-','아거','-','거부기','-','-','-','-','-','-','-','-']
            },
        // 46
            {
              'title' : ['hospital'],
              'front' : ['내과','외과','치과','정형외과','안과','이비인후과','성형외과','피부과','소아과','산부인과','응급실','한의원'],
              'back' : ['internal medicine','general surgery','dental','orthopedic surgery','ophthalmology','otolaryngology/ENT','plastic surgery','dermatology','pediatric','obstetrics and gynecology','emergency room','oriental medical clinic'],
              'pronunciation' : ['내꽈','외꽈','치꽈','정형외꽈','안꽈','이비인후꽈','성형외꽈','피부꽈','소아꽈','산부인꽈','-','하니원']
            },
        // 47
            {
              'title' : ['sickness'],
              'front' : ['아프다','몸이 안 좋다','병에 걸리다','감기에 걸리다','콧물이 나다','열이 나다','기침이 나다','코가 막히다','약','주사를 맞다','입원하다','피가 나다','눈물이 나다','여드름이 나다','체하다','가렵다','어지럽다','답답하다','멀미가 나다'],
              'back' : ['sick','not feeling well','get sick','catch a cold','runny nose','have a fever','have a cough','stuffy nose','medicine','get an injection','hospitalize','bleeding','tears flow','get acne','indigestion','itchy','dizzy','feel heavy','motion sickness'],
              'pronunciation' : ['-','모미안조타','-','-',',콘물이나다','여리나다','기치미나다','코가마키다','-','-','이붠하다','-','눈무리나다','여드르미나다','-','가렵따','-',',답다파다','-']
            },
        // 48
            {
              'title' : ['accident'],
              'front' : ['다치다','넘어지다','교통사고가 나다','불이 나다','떨어지다','뼈가 부러지다','까지다','붓다','데이다','멍들다','삐다','찔리다','베이다','뼈가 빠지다','약을 바르다','반창고를 붙이다','침을 맞다','찜질하다','수술받다'],
              'back' : ['hurt','fall down','have a car accident','fire breaks out','fall','break','scratch','puffy','burn','bruise','sprain','prick','cut','dislocation','apply medicine','apply a band-aid','get acupuncture','apply a hot pack','operate'],
              'pronunciation' : ['-','너머지다','-','부리나다','떠러지다','-','-','붇따','-','-','-','-','-','-','야글바르다','반창꼬를부치다','치믈맏따','-','-']
            },
        //49
            {
              'title' : ['emotion1'],
              'front' : ['좋아하다','싫어하다','기쁘다','슬프다','무섭다','울다','웃다','기분이 좋다','기분이 나쁘다','사랑하다','걱정하다','외롭다','놀라다','심심하다','짜증이 나다','행복하다','부럽다','마음에 들다','관심이 있다','스트레스를 받다','스트레스를 풀다','화가 나다','화를 풀다'],
              'back' : ['like','hate','glad','sad','scary','cry','laugh','feel good','feel bad','love','worry','lonely','be surprised','bored','irritated','happy','envy','take a liking','interested','under stress','relieve stress','get angry','blow off steam'],
              'pronunciation' : ['조아하다','시러하다','-','-','무섭따','-','욷따','기부니조타','기부니나쁘다','-','걱쩡하다','외롭따','-','-','-','행보카다','부럽따','-','관시미읻따','스트레스를받따','-','-','-']
            },
        // 50
            {
              'title' : ['emotion2'],
              'front' : ['실망하다','부끄럽다','싫증이 나다','겁이 나다','참다','기대하다','부담되다','당황하다','만족하다','신기하다','대단하다','불쌍하다','지루하다','그립다','아쉽다','후회하다','안심하다','긴장하다','오해하다','지겹다','귀찮다','어색하다'],
              'back' : ['disappointed','embarrassing','get tired of','scared','endure','looking forward','pressured','freak out','satisfied','interesting','awesome','pitiful','mind numbing','miss','That\'s a shame','regret','relieved','nervous','misunderstand','be tired of','feel lazy','awkward'],
              'pronunciation' : ['-','부끄럽따','실쯩이나다','거비나다','참따','-','-','-','만조카다','-','-','-','-','그립따','아쉽따','-','-','-','-','지겹따','귀찬타','어새카다']
            },
        // 51
            {
              'title' : ['adverb1'],
              'front' : ['항상','보통','자주','가끔','별로','거의','전혀','아주','너무','정말','조금','많이','더','덜'],
              'back' : ['always','normally','often','sometimes','not much','almost not','never','very','too','really','a little bit','much','more','less'],
              'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','마니','-','-']
            },
        // 52
            {
              'title' : ['adverb2'],
              'front' : ['다/모두','갑자기','열심히','아마','먼저','점점','자세히','대충','직접','몰래','급하게','겨우','같이','혼자'],
              'back' : ['all','suddenly','hard','probably','first','more and more','in detail','roughly','directly','sneak','urgently','only','together','alone'],
              'pronunciation' : ['-','갑짜기','-','-','-','-','-','-','직쩝','-','그파게','-','가치','-']
            },
        // 53
            {
              'title' : ['adjective1'],
              'front' : ['좋다','나쁘다','재미있다','재미없다','바쁘다','힘들다','어렵다','쉽다','인기가 많다','유명하다','필요하다','필요없다','더럽다','깨끗하다','많다','적다','같다','다르다','빠르다','느리다'],
              'back' : ['good','bad','funny','not funny','busy','hard','difficult','easy','popular','famous','need','no need','dirty','clean','a lot','few','same','different','fast','slow'],
              'pronunciation' : ['조타','-','재미읻따','재미업따','-','-','어렵따','쉽따','인끼가만타','-','피료하다','피료업따','더럽따','깨끄타다','만타','적따','갇따','-','-','-']
            },
        // 54
            {
              'title' : ['adjective2'],
              'front' : ['높다','낮다','밝다','어둡다','알다','모르다','차갑다','미지근하다','뜨겁다','편하다','편리하다','불편하다','무겁다','가볍다','간단하다','복잡하다','위험하다','안전하다','중요하다'],
              'back' : ['high','low','bright','dark','know','not know','cold','lukewarm','hot','comfortable','convenient','uncomfortable','heavy','light','simple','complicated','dangerous','safe','important'],
              'pronunciation' : ['놉따','낟따','박따','어둡따','-','-','차갑따','-','뜨겁따','-','펼리하다','-','무겁따','가볍따','-','복자파다','-','-','-']
            },
        // 55
            {
              'title' : ['adjective3'],
              'front' : ['이상하다','고장나다','잃어버리다','이기다','지다','늘다','줄다','생기다','궁금하다','얼다','녹다','오르다','내리다','깨지다','부러지다','남다','모이다','막히다'],
              'back' : ['weird','break down','lost','win','defeated','increase','decrease','come up','curious','frozen','melt','rise','fall','broken','break','remain','get together','blocked'],
              'pronunciation' : ['-','-','이러버리다','-','-','-','-','-','-','-','녹따','-','-','-','-','남따','-','마키다']
            },
        // 56
            {
              'title' : ['adjective4'],
              'front' : ['바뀌다','시끄럽다','효과가 있다','익숙하다','어울리다','찢어지다','충분하다','부족하다','운이 좋다','도움이 되다','건강하다'],
              'back' : ['changed','noisy','effective','familiar','match','tear','enough','lack','lucky','helpful','healthy'],
              'pronunciation' : ['-','시끄럽따','효꽈가읻따','익쑤카다','-','찌저지다','-','부조카다','우니조타','도우미되다','-']
            },
        // 57
            {
              'title' : ['verb1'],
              'front' : ['듣다','쓰다','읽다','보다','말하다','얘기하다','열다','닫다','주다','받다','보내다','일하다','쉬다','자다','일어나다','입다','벗다','먹다','마시다','만나다','취하다','설명하다','이해하다','꺼내다'],
              'back' : ['listen','write','read','see/watch','speak','talk','open','close','give','receive','send','work','rest','sleep','wake up','wear','take off','eat','drink','meet','get drunk','explain','understand','pull out'],
              'pronunciation' : ['듣따','-','익따','-','-','-','-','닫따','-','받따','-','-','-','-','이러나다','입따','벋따','먹따','-','-','-','-','-','-']
            },
        // 58
            {
              'title' : ['verb2'],
              'front' : ['앉다','서다','놀다','찾다','버리다','도와주다','질문하다','대답하다','소개하다','추천하다','켜다','끄다','들다','생각하다','기억하다','경험하다','연습하다','운전하다','기다리다','화장하다','잡다','놓다','사과하다','외우다'],
              'back' : ['sit','stand','play/hang out','find','throw away','help','ask','answer','introduce','recommend','turn on','turn off','hold/pick up','think','remember','experience','practice','drive','wait','put on makeup','catch','put','apologize','memorize'],
              'pronunciation' : ['안따','-','-','찯따','-','-','-','대다파다','-','-','-','-','-','생가카다','기어카다','-','연스파다','-','-','-','잡따','노타','-','-']
            },
        // 59
            {
              'title' : ['verb3'],
              'front' : ['주문하다','초대하다','줄을 서다','꿈을 꾸다','담배를 피우다','담배를 끄다','담배를 끊다','거짓말을 하다','눕다','늦잠을 자다','싸우다','펴다','덮다','밀다','당기다','눈을 감다','눈을 뜨다','냄새를 맡다','제안하다','거절하다','빌려주다','빌리다','돌려주다','알리다','세우다'],
              'back' : ['order','invite','stand in line','dream','smoke','put out a cigarette','quit smoking','tell a lie','lie down','oversleep','fight','unfold','cover','push','pull','close eyes','open eyes','smell','propose','refuse','lend','rent','give back','notify','set up'],
              'pronunciation' : ['-','-','주를서다','꾸믈꾸다','-','-','담배를끈타','거진마를하다','눕따','늗짜믈자다','-','-','덥따','-','-','누늘감따','누늘뜨다','냄새를맏따','-','-','-','-','-','-','-']
            },
        // 60
            {
              'title' : ['verb4'],
              'front' : ['만지다','악수하다','때리다','맞다','부탁하다','박수치다','칭찬하다','선택하다/고르다','월세를 내다','혼내다','혼나다','밟다','하품하다','뽀뽀하다','불평하다','변명하다','묶다','풀다','속다','속이다','남기다','맡기다','모으다'],
              'back' : ['touch','shake hands','hit','be hit','request','clap','praise','choose','pay monthly rent','scold','get scolded','step on','yawn','kiss','complain','give an excuse','tie','solve','be deceived','deceive','leave','leave sth to sb','gather'],
              'pronunciation' : ['-','악쑤하다','-','맏따','부타카다','박쑤치다','-','선태카다','월쎄를내다','-','-','밥따','-','-','-','-','묵따','-','속따','소기다','-','맏끼다','-']
            },
    ]

// --- 헬퍼 함수: 파일 존재 확인 및 Base64 인코딩 ---
function getBase64Image(filePath) {
  // 1. 파일이 존재하는지 먼저 확인
  if (fs.existsSync(filePath)) {
    // 2. 파일을 읽어 Base64 문자열로 변환
    const fileBuffer = fs.readFileSync(filePath);
    return `${fileBuffer.toString('base64')}`;
  }
  return null; // 파일이 없으면 null 반환
}

// --- 헬퍼 함수: MP3를 M4A로 변환 ---
async function convertToM4a(sourcePath) {
  // 임시 폴더에 저장될 M4A 파일의 경로 생성
  const tempFileName = `${path.basename(sourcePath, '.mp3')}.m4a`;
  const outputPath = path.join(os.tmpdir(), tempFileName);

  // FFmpeg 변환 명령어
  // -i: 입력 파일, -c:a aac: 오디오 코덱을 AAC로 지정, -b:a 128k: 오디오 비트레이트를 128kbps로 설정
  const command = `ffmpeg -y -i "${sourcePath}" -vn -c:a aac -b:a 128k "${outputPath}"`;

  try {
    console.log(`  - 변환 시작: ${path.basename(sourcePath)} -> ${tempFileName}`);
    await promisifiedExec(command);
    console.log(`  - 변환 성공: ${tempFileName}`);
    return outputPath; // 변환된 파일의 경로 반환
  } catch (error) {
    console.error(`  - FFmpeg 변환 오류: ${error}`);
    throw error; // 오류 발생 시 중단
  }
}

async function migration() {
console.log('데이터 마이그레이션을 시작합니다...');

  try {
    for (const [topicIndex, topicData] of dataToMigrate.entries()) {
      const topicTitle = topicData.title[0];
      const topicId = uuidv4();

      console.log(`[${topicIndex}] Topic 처리 시작: ${topicTitle}`);

      // --- 오디오 처리 로직 변경 ---
      // Promise.all 대신 for...of 루프를 사용하여 순차적으로 처리합니다.
      const audioUrlMap = new Map();

      console.log(`  - 오디오 파일 순차 처리 시작...`);
      // topicData.front.entries()를 사용해 인덱스와 값을 함께 가져옵니다.
      for (const [wordIndex, _] of topicData.front.entries()) {
        const audioPathMp3 = path.join(__dirname, '..', 'assets', 'audio', `${topicIndex}_${wordIndex}.mp3`);
        const wordId = uuidv4(); // 각 단어의 UUID는 여기서 생성

        let audioUrl = null; // 기본 URL은 null

        // 1. MP3 파일이 존재하는 경우에만 변환 및 업로드 진행
        if (fs.existsSync(audioPathMp3)) {
          console.log(`    - [${wordIndex}] 파일 발견: ${path.basename(audioPathMp3)}`);

          // 2. M4A로 변환 (await로 작업이 끝날 때까지 대기)
          const m4aPath = await convertToM4a(audioPathMp3);

          // 3. Storage에 업로드 (await로 작업이 끝날 때까지 대기)
          const destination = `audios/${topicId}/${wordId}.m4a`;
          const [file] = await bucket.upload(m4aPath, { destination });

          // 4. 임시 파일 삭제
          fs.unlinkSync(m4aPath);

          // 5. 다운로드 URL 가져오기
          const [url] = await file.getSignedUrl({ action: 'read', expires: '03-09-2491' });
          audioUrl = url;

          console.log(`    - [${wordIndex}] 업로드 및 URL 생성 완료.`);
        }

        // 6. 최종 결과를 맵에 저장
        audioUrlMap.set(wordIndex, { wordId: wordId, url: audioUrl });
      }
      console.log(`  - 모든 오디오 파일 처리 완료.`);
      // --- 오디오 처리 로직 변경 완료 ---


      // Firestore에 저장하는 로직은 이전과 동일합니다.
      const batch = db.batch();

      const topicRef = db.collection('Topics').doc(topicId);
      const topicImagePath = path.join(__dirname, '..', 'assets', 'images', `${topicIndex}.png`);
      const topicImageBase64 = getBase64Image(topicImagePath);

      const topicDoc = {
        id: topicId,
        orderId: topicIndex,
        title: topicTitle,
        isReleased: true,
        image: topicImageBase64 || "",
      };
      batch.set(topicRef, topicDoc);

      topicData.front.forEach((frontWord, wordIndex) => {
        const { wordId, url: audioUrl } = audioUrlMap.get(wordIndex);
        const wordRef = topicRef.collection('Words').doc(wordId);
        const wordImagePath = path.join(__dirname, '..', 'assets', 'images', 'words', `${topicIndex}-${wordIndex}.png`);
        const wordImageBase64 = getBase64Image(wordImagePath);

        const wordDoc = {
          id: wordId,
          orderId: wordIndex,
          front: frontWord,
          back: topicData.back[wordIndex],
          pronunciation: topicData.pronunciation[wordIndex],
          isReleased: true,
        };

        if (wordImageBase64) {
          wordDoc.image = wordImageBase64;
        }

        batch.set(wordRef, wordDoc);
      });

      await batch.commit();
      console.log(`  └> 성공: '${topicTitle}' Topic 및 ${topicData.front.length}개의 단어가 Firestore에 생성되었습니다.`);
    }

    console.log('\n🎉 모든 데이터 마이그레이션이 성공적으로 완료되었습니다.');

  } catch (error) {
    console.error('\n💥 마이그레이션 중 심각한 오류 발생:', error);
  }
}

async function updateAudioUrls() {
  console.log('오디오 URL 업데이트 작업을 시작합니다...');

  try {
    // 1. 모든 Topic 문서 가져오기
    const topicsSnapshot = await db.collection('Topics').get();
    console.log(`총 ${topicsSnapshot.size}개의 Topic을 발견했습니다.`);

    // 2. 각 Topic을 순차적으로 순회
    for (const topicDoc of topicsSnapshot.docs) {
      const topicId = topicDoc.id;
      const topicTitle = topicDoc.data().title;
      console.log(`\n[Topic 처리 시작] ${topicTitle} (ID: ${topicId})`);

      // 3. 해당 Topic 하위의 모든 Word 문서 가져오기
      const wordsRef = topicDoc.ref.collection('Words');
      const wordsSnapshot = await wordsRef.get();

      if (wordsSnapshot.empty) {
        console.log(`  └> 이 Topic에는 단어가 없습니다. 다음으로 넘어갑니다.`);
        continue; // 다음 Topic으로
      }

      console.log(`  - ${wordsSnapshot.size}개의 단어를 확인합니다...`);

      // 4. 이 Topic의 모든 Word 업데이트를 위한 WriteBatch 생성
      const batch = db.batch();
      let updatesCount = 0;

      // 5. 각 Word에 대한 URL 가져오기 작업을 병렬로 처리
      const updatePromises = wordsSnapshot.docs.map(async (wordDoc) => {
        const wordId = wordDoc.id;
        const filePath = `audios/${topicId}/${wordId}.m4a`;
        const file = bucket.file(filePath);

        // 6. Storage에 해당 오디오 파일이 있는지 확인
        const [exists] = await file.exists();

        if (exists) {
          // 7. 파일이 있으면 공개 URL을 가져와서 배치에 업데이트 작업 추가
          const [url] = await file.getSignedUrl({
            action: 'read',
            expires: '03-09-2491', // 사실상 영구적인 URL
          });

          batch.update(wordDoc.ref, { audio: url });
          updatesCount++;
          // console.log(`    - URL 준비: ${wordId}`);
        }
      });

      // 8. 이 Topic의 모든 단어에 대한 URL 가져오기 작업이 끝날 때까지 대기
      await Promise.all(updatePromises);

      // 9. 업데이트할 내용이 있으면 배치 커밋
      if (updatesCount > 0) {
        await batch.commit();
        console.log(`  └> 성공: ${updatesCount}개의 단어에 오디오 URL을 업데이트했습니다.`);
      } else {
        console.log(`  └> 업데이트할 오디오 파일이 없습니다.`);
      }
    }

    console.log('\n🎉 모든 Topic의 오디오 URL 업데이트 작업이 완료되었습니다.');

  } catch (error) {
    console.error('\n💥 작업 중 심각한 오류 발생:', error);
  }
}

async function checkLoraDatabase() {
// 1. 'MyWords' 컬렉션에서 모든 문서 ID를 가져옵니다.
    const myWordsCollectionPath = 'Users/FXgPnE6r6xPLu70zCSmZ7F5vWDK2/MyWords';
    console.log(`1. '${myWordsCollectionPath}'에서 문서 ID를 가져오는 중...`);

    const myWordsSnapshot = await db.collection(myWordsCollectionPath).get();

    // 문서 ID만 추출하여 배열에 저장합니다. (문서 자체가 아니라 ID만 필요)
    const myWordIds = myWordsSnapshot.docs.map(doc => doc.id);

    if (myWordIds.length === 0) {
        console.log("👉 MyWords 컬렉션에 문서가 없습니다. 작업을 종료합니다.");
        return;
    }
    console.log(`✅ 가져온 MyWords ID (${myWordIds.length}개):`, myWordIds);
    console.log("-----------------------------------------");

    // 2. 'Words' 컬렉션 그룹에서 일치하는 문서를 찾습니다.
    console.log("2. Topics 컬렉션 그룹에서 일치하는 'Words' 문서를 검색하는 중...");

    // **컬렉션 그룹 쿼리 사용**: 데이터베이스의 모든 'Words' 컬렉션에 접근합니다.
    const wordsCollectionGroupRef = db.collectionGroup('Words');

    // Firestore `in` 쿼리는 최대 10개의 요소만 지원합니다.
    // myWordIds가 10개를 초과할 수 있으므로, 배열을 10개 단위로 분할하여 처리해야 합니다.
    const batchSize = 10;
    const batches = [];
    for (let i = 0; i < myWordIds.length; i += batchSize) {
        batches.push(myWordIds.slice(i, i + batchSize));
    }

    let totalMatches = 0;

    for (const batch of batches) {
        // Words 문서의 ID는 Topic 문서의 ID와는 다를 수 있습니다.
        // 따라서 MyWords의 ID가 Words 문서의 ID와 일치하는지 확인하기 위해
        // Words 문서의 ID를 기준으로 쿼리를 실행합니다.

        // **중요:** where(admin.firestore.FieldPath.documentId(), 'in', batch)를 사용합니다.
        const query = wordsCollectionGroupRef.where('id', 'in', batch);

        const matchingWordsSnapshot = await query.get();

        console.log(`\n** 검색 결과 (배치 ${batches.indexOf(batch) + 1}/${batches.length}) **`);

        if (matchingWordsSnapshot.empty) {
            console.log("  ➡️ 일치하는 Words 문서를 찾지 못했습니다.");
            continue;
        }

        matchingWordsSnapshot.forEach(doc => {
            const wordData = doc.data();
            const front = wordData.front;

            console.log(`  🔍 ID: ${doc.id} | front: "${front}"`);
            totalMatches++;
        });
    }

    console.log("-----------------------------------------");
    console.log(`🎉 모든 검색 완료. 총 ${totalMatches}개의 일치하는 단어의 'front' 필드를 출력했습니다.`);

}

async function getAudioPath() {
    const filePath = 'audios/8a086dd0-1598-41cd-8950-8694ed9f62d0/8fb90472-940b-42ff-bdc3-97ce0c39d3d8';
    // 기본 스토리지 버킷을 가져옵니다.
      const bucket = admin.storage().bucket();
      const file = bucket.file(filePath);

      const [exists] = await file.exists();

        // 7. 파일이 있으면 공개 URL을 가져와서 배치에 업데이트 작업 추가
        const [url] = await file.getSignedUrl({
          action: 'read',
          expires: '03-09-2491', // 사실상 영구적인 URL
        });
        console.log(url);


}

getAudioPath();