PImage TitleImg;
PImage mapImg; //マップ画像
PImage mcImg; //自キャラ画像
PImage mcDeadImg;
PImage enemyImg; //敵画像
PImage enemy2Img;
PImage BossImg;
PImage BossRedImg;
PImage BossAttackImg;
PImage MbImg;
PImage EbImg;
int gameMode = 0; //スタート画面=0,ゲーム画面=1,ゲームオーバー画面=2,クリア画面=3
int count;
int score = 0; 
int Life = 1;
int next_shot_num = 0;
int eNum;
int e2Num;
float BossHP;
int BossCount = 0;

MyCharacter mc; //自キャラのインスタンス用変数を宣言

Map m1;
EnemyBullet[] Eb = new EnemyBullet[10];
Enemy[] e = new Enemy[20];
Enemy[] e2 = new Enemy[20];
Boss boss;
McBullet[] Mb = new McBullet[30];
EnemyBullet Bb;
BossAttack Ba;

void setup() {
  size(500, 400);
  frameRate(60);  //1秒間に60回描画する
  TitleImg = loadImage("title.gif");
  mapImg = loadImage("background.gif"); //マップ画像を読み込む
  mcImg = loadImage("mcp.gif"); //自キャラ画像を読み込む
  mcDeadImg = loadImage("mcp_dead.gif");
  enemyImg = loadImage("enemy1.gif");
  enemy2Img = loadImage("enemy2.gif");
  BossImg = loadImage("boss.gif");
  BossRedImg = loadImage("boss_red.gif");
  BossAttackImg = loadImage("boss_attack.gif");
  EbImg = loadImage("enemy_bullet.gif");
  MbImg = loadImage("mcp_bullet.gif");
  m1 = new Map();
  mc = new MyCharacter();
  boss = new Boss();   
  Bb = new EnemyBullet();
  Ba = new BossAttack();
  for (int i = 0; i < e.length; i++) {
    e[i] = new Enemy();
  }
  for (int i = 0; i < e2.length; i++) {
    e2[i] = new Enemy();
  }
  for (int i = 0; i < Mb.length; i++) {
    Mb[i] = new McBullet();
  }
  for (int i = 0; i < Eb.length; i++) {
    Eb[i] = new EnemyBullet();
  }
  setting();
}

void setting() {
  count = 0;
  score = 0; 
  Life = 1;
  next_shot_num = 0;
  BossHP = 20;
  BossCount = 0;
  m1.x = 0;
  m1.y = -2100;
  m1.vy = 1;
  mc.Damage = false;
  mc.x = 250;
  mc.y = 360;
  mc.vx = 1;
  mc.vy = 1;
  boss.flag = false;
  boss.Dead =false;
  boss.x = 250;
  boss.y = -160;
  for (int i = 0; i < Mb.length; i++) {
    Mb[i].Dead = true;
  }
  for (int i = 0; i < e.length; i++) {
    e[i].Dead = true;
    e[i].life = 1;
  }
  for (int i = 0; i < e2.length; i++) {   
    e2[i].Dead = true;
    e2[i].life = 5;
    e2[i].vx = random(-0.4, 0.4);
    e2[i].vy = random(-0.4, 0.4);
  }
  for (int i = 0; i < Eb.length; i++) {
    Eb[i].x = boss.x;
    Eb[i].y = boss.y;
    Eb[i].vx = random(0, 3);
    Eb[i].vy = 3 + random(1);
    ;
    if (random(1) < 0.5) {
      Eb[i].vx *= -1;
    }
  }
}

void draw() {
  //drawメソッド内で表示する画面を切り替える
  if (gameMode == 0) { //スタート画面
    drawStart();
  } else if (gameMode == 1) { //ゲーム画面
    drawGame();
  } else if (gameMode == 2) { //ゲームオーバー画面
    drawGameOver();
  } else if (gameMode == 3) { //ゲームクリア画面
    drawClear();
  }
}

//スタート画面を描画
void drawStart() {
  background(0);
  image(TitleImg, 56, 100);
  PFont font = createFont("MS Gothic", 20, true);
  textFont(font);
  textSize(20);
  fill(255, 255, 255);
  text("スペースキーで開始", 150, 310);  
  textSize(14);
  text("移動 : AWSD", 150, 260);
  text("攻撃 : K", 150, 280);
  if (keyCode == ' ') {//スペースキーを押したらスタート    
    gameMode = 1;  //gameModeを1にする
  }
}

//ゲーム画面を描画
void drawGame() {
  gameMode();
  drawBG(); 
  moveMc();
  drawMb();
  drawBb();
  drawBoss();
  drawMc();
  drawWave();
  checkDist();
  dispScore();//得点を計算し、表示する
  drawBossHP();
  count++;
}

//背景を描画
void drawBG() {
  background(255);
  image(mapImg, m1.x, m1.y, 500, 2500);
  if (m1.y < 0) {
    m1.vy = 1;
  } else if (m1.y >= 0) {
    m1.vy = 0;
    boss.flag = true;
  }
  m1.y += m1.vy;
}

//自キャラを動かす.
void moveMc() {
  if (keyPressed == false) {
    mc.vx = 0; //速度を0にする
    mc.vy = 0;
  }
  if (mc.x < 0) {
    mc.x = 8;
  } else if (mc.x >= width) {
    mc.x = (width - 8);
  } else if (mc.y < 0) {
    mc.y = 8;
  } else if (mc.y >= height) {
    mc.y = (height - 8);
  }
  mc.x += mc.vx; //速度を自キャラの座標に足す
  mc.y += mc.vy;
}

void checkDist() {
  for (int i = 0; i < e.length; i++) {
    for (int a = 0; a < Mb.length; a++) {
      if (dist(mc.x, mc.y, e[i].x, e[i].y) <= 20) {
        if (e[i].Dead == false) {
          Life -= 1;
        }
      } 
      if (dist(e[i].x, e[i].y, Mb[a].x, Mb[a].y) <= 18) {
        if (e[i].Dead == false && Mb[a].Dead == false) {
          Mb[a].Dead = true;
          e[i].life -= 1;
        }
      }
    }
  }
  for (int i = 0; i < e2.length; i++) {
    for (int a = 0; a < Mb.length; a++) {
      if (dist(mc.x, mc.y, e2[i].x, e2[i].y) <= 20) {
        if (e2[i].Dead == false) {         
          Life -= 1;
        }
      } 
      if (dist(e2[i].x, e2[i].y, Mb[a].x, Mb[a].y) <= 18) {
        if (e2[i].Dead == false && Mb[a].Dead == false) {
          Mb[a].Dead = true;
          e2[i].life -= 1;
        }
      }
    }
  }
}

void gameMode() {
  if (Life <= 0) {
    gameMode = 2;
  } else if (boss.Dead == true) {
    gameMode = 3;
  }
}

//得点を計算し、表示する
void dispScore() {
  textSize(20);
  stroke(20, 20, 20);
  fill(255, 255, 255);
  text("score:" + score, 10, 380);
}

void drawMc() {  
  if (Life <= 0) {
    mc.Damage = true;
  }
  imageMode(CENTER);
  if (mc.Damage == false) {
    image(mcImg, mc.x, mc.y);
  } else if (mc.Damage == true) {
    image(mcDeadImg, mc.x, mc.y);
  }
  imageMode(CORNER);
}

void drawMb() {
  for (int i = 0; i < Mb.length; i++) {  
    if (Mb[i].Dead == false) {
      Mb[i].vy = -8;
      Mb[i].y += Mb[i].vy;
      imageMode(CENTER);
      image(MbImg, Mb[i].x, Mb[i].y);
      imageMode(CORNER);
      if (Mb[i].x > width || Mb[i].x < 0 || Mb[i].y > height || Mb[i].y < 0) {
        Mb[i].Dead = true;
        Mb[i].Start = true;
      }
    }
  }
}
void drawEb() {
  for (int i = 0; i < Eb.length; i++) {  
    if (Eb[i].Dead == false) {
      imageMode(CENTER);
      image(EbImg, Eb[i].x, Eb[i].y);
      imageMode(CORNER);       
      if (dist(mc.x, mc.y, Eb[i].x, Eb[i]. y) < 18) {
        Life -= 1;
      }
      Eb[i].x += Eb[i].vx;
      Eb[i].y += Eb[i].vy;
    }
  }
}

void drawWave() {
  if (boss.flag == false) {
    if (count % (40 + (int)random(0, 100))== 0) {
      e[eNum].Dead = false;
      e[eNum].x = random(0, width);
      e[eNum].y = 0;
      eNum ++;
      if (eNum >= e.length) {
        eNum = 0;
      }
    }
    for (int i = 0; i < e.length; i++) {   
      if (e[i].Dead == false) {
        e[i].Enemy1draw();
        if (dist(mc.x, mc.y, e[i].x, e[i].y) < 300) {
          e[i].y += 1;
          if (mc.x < e[i].x) {
            e[i].x -= 0.6;
          } else if (mc.x > e[i].x) {
            e[i].x += 0.6;
          }
        }
      }
    }
    if (count % (30 + (int)random(0, 50))== 0) {
      e2[e2Num].Dead = false;
      e2[e2Num].x = random(0, width);
      e2[e2Num].y = 0;
      e2Num ++;
      if (e2Num >= e2.length) {
        e2Num = 0;
      }
    }
    for (int i = 0; i < e.length; i++) {   
      if (e[i].Dead == false) {
        e[i].Enemy1draw();
        if (dist(mc.x, mc.y, e[i].x, e[i].y) < 300) {
          e[i].y += 0.8;
          if (mc.x < e[i].x) {
            e[i].x -= 0.8;
          } else if (mc.x > e[i].x) {
            e[i].x += 0.8;
          }
        }
      }
    }
    for (int i = 0; i < e2.length; i++) {   
      if (e2[i].Dead == false) {
        e2[i].x += e2[i].vx;
        e2[i].y += e2[i].vy;
        e2[i].Enemy2draw();
      }
    }
  }
}
void drawBoss() {
  if (boss.flag == true) {
    for(int i = 0; i < e.length; i++){
       e[i].Dead = true;
    }
    for(int i = 0; i < e2.length; i++){
       e2[i].Dead = true;
    }
    BossCount++;
    if (BossCount > 10 && BossCount < 120) {
      textSize(40);
      fill(200, 200, 200);
      text("Boss Battle", 130, height/2);
    }
    if (BossHP <= 0) {
      boss.Dead = true;
    }
    if (BossCount % 300 == 0) {
      boss.vx = 0;
    } else if ((BossCount + 120) % 300 == 0 && BossCount > 120 ) {
      boss.vx = 2;
    }
    if (BossCount % 240 == 0) {
      Bb.flag = true;
    } 
    if ((BossCount + 1) %  240 == 0) {
      Bb.flag = false;
      Bb.x = boss.x;
      Bb.y = boss.y;
      for (int i = 0; i < Eb.length; i++) {        
        Eb[i].x = boss.x;
        Eb[i].y = boss.y;
      }
    }
    if (BossCount % 1200 >= 1080 && BossHP > 10) {
      Ba.flag = true;
    } 
    if (BossCount % 1200 >= 1120 && BossHP > 10) {
      Ba.flag = false;
      Ba.x = boss.x;
      Ba.y = boss.y + 270;
      Ba.draw();
    } 
    if (BossCount % 200 >= 80 && BossHP <= 10) {
      Ba.flag = true;
    } 
    if (BossCount % 200 >= 120 && BossHP <= 10) {
      Ba.flag = false;
      Ba.x = boss.x;
      Ba.y = boss.y + 270;
      Ba.draw();
    } 
    boss.Bossdraw();
  }
}

void drawBb() {
  if (Bb.flag == true && boss.flag == true) {
    drawEb();
  }
}

void drawBossHP() {
  if (boss.flag == true) {
    textSize(20);
    fill(200, 200, 200);
    text("Boss HP", 220, 26);
    stroke(255, 255, 255);
    fill(0, 0, 0);
    rect(299, 10, 162, 18);
    noStroke();
    fill(200, 0, 0);
    if (BossHP >= 0) {
      rect(300, 11, BossHP*8, 16);
    }
  }
}

//クリア画面を描画
void drawClear() {
  textSize(50);
  fill(200, 200, 200);
  text("Game Clear!", 100, 180); 
  textSize(20);
  text("Clear score: " + score, 130, 260);
  textSize(16);
  text("Please Press Enter Key", 130, 320);
}

//GameOver画面を描画
void drawGameOver() {  
  textSize(40);
  fill(200, 200, 200);
  text("Game Over!", 130, height/2);
  textSize(16);
  text("Please Press Enter Key", 130, 320);
  if (keyCode == TAB) {   
    gameMode = 1;
    Life = 200;
  }
}

void keyPressed() {
  if (keyCode == 'K') {
    Mb[next_shot_num].Dead = false;
    Mb[next_shot_num].x = mc.x;      
    Mb[next_shot_num].y = mc.y;      
    next_shot_num ++;
    if (next_shot_num >= Mb.length) {
      next_shot_num = 0;
    }
  }
  if (keyCode == 'A') {
    mc.vx = -4;
  } else if (keyCode == 'W') {
    mc.vy = -4;
  } else if (keyCode == 'S') {
    mc.vy = 4;
  } else if (keyCode == 'D') {
    mc.vx = 4;
  }
  if (keyCode == ENTER) {
    if (gameMode == 2 || gameMode == 3) {
      setting();
      gameMode = 0;
    }
  }
}


class MyCharacter {
  int x;
  int y;
  int vx;
  int vy;
  Boolean Damage = false;
}
class McBullet {
  int x;
  int y;
  int vx;
  int vy;
  Boolean Dead = false;
  Boolean Start = true;
  void draw() {
    for (int i = 0; i < Mb.length; i++) {  
      if (Mb[i].Dead == false) {
        imageMode(CENTER);
        image(MbImg, Mb[i].x, Mb[i].y);
        imageMode(CORNER);
        if (Mb[i].Start == false) {
          Mb[i].y += -12;
        } 
        if (Mb[i].x > width || Mb[i].x < 0 || Mb[i].y > height || Mb[i].y < 0) {
          Mb[i].Dead = true;
          Mb[i].Start = true;
        }
      }
    }
  }
}

class Enemy {
  float x;
  float y;
  float vx;
  float vy;
  int life;
  boolean Dead = false;
  void Enemy1draw() {
    if (Dead == false) {
      imageMode(CENTER);
      image(enemyImg, x, y);
      imageMode(CORNER);
      y += 1;
    }
    if (y > height) {
      Dead = true;
    }
    if (life <= 0) {
      Dead = true;
      score += 100;
    }
  }
  void Enemy2draw() {
    if (Dead == false) {
      imageMode(CENTER);
      image(enemy2Img, x, y);
      imageMode(CORNER);
      y += 1;
    }
    if (y > height) {
      Dead = true;
    }
    if (life <= 0) {
      Dead = true;
      score += 100;
    }
  }
}

class Boss {
  int x;
  int y;
  int vx;
  int vy;
  boolean flag = false;
  boolean Dead = false;
  void Bossdraw() {
    if (Dead == false) {
      imageMode(CENTER);
      if (Ba.flag == false) {
        image(BossImg, x, y);
      } else if (Ba.flag == true) {
        image(BossRedImg, x, y);
      }
      imageMode(CORNER);
      x += vx;
      if (y<40) {
        y += 2;
      }
      if (x > 460 || x < 40) {
        vx *= -1;
      }
      if (dist(mc.x, mc.y, x, y) < 96) {
        Life -= 1;
      }
      for (int i = 0; i < Mb.length; i++) {
        if (dist(Mb[i].x, Mb[i].y, x, y) < 96 && Mb[i].Dead == false) {
          Mb[i].Dead = true;
          BossHP -= 1;
          score += 100;
        }
      }
    }
  }
}

class EnemyBullet {
  int Dice;
  float x;
  float y;
  float vx;
  float vy;
  boolean flag = false;
  boolean Dead = false;
  boolean Start = true;//発射時か発射後かの判別
  void draw() {  
    for (int i=0; i<3; i++) {     
      imageMode(CENTER);
      image(EbImg, x, y);
      imageMode(CORNER);       
      if (dist(mc.x, mc.y, x, y) < 18) {
        Life -= 1;
      }
    }
  }
}

class BossAttack {
  float x;
  float y;
  boolean flag = false;
  boolean Dead = false;
  void draw() {     
    imageMode(CENTER);
    image(BossAttackImg, x, y);
    imageMode(CORNER);           
    if (mc.x > (x - 40) && mc.x < (x + 40)) {
      Life -= 1;
    }
  }
}

class Map {
  int x;
  int y;
  int vx;
  int vy;
}
