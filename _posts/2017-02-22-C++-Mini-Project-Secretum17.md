---
layout: post
title:  "C++ MINI PROJECT"
description: 파일 암호화 프로그램
date:   2017-02-22
tag: [project, C++, Encryption]
comments: true
share: true
---

Secretum17
==========

#### C++ 미니 암호화 프로젝트

개발 기간 : 2017.02.01 ~ 2017.02.17  
개발 환경 : Window 10 x64, Visual studio 2015  
소스 코드 : <https://github.com/rlarlgns/Secretum17>

-------

content
---
  1. 프로젝트 개요  

  2. 개발내용  
    2.1 개발목표  
    2.2 프로젝트 알고리즘 구현  
    2.3 객체 지향적 코드 구현  
    2.4 UI 구성  

  3. 결과 및 성과  

----------

1.개요
----

본 프로젝트는 C++ 암호화 프로그램을 제작하면서 기본적인 암호화 알고리즘에 대한 이해와 객체지향 프로그래밍을 실습하는 것을 목표로 한다. DES 블록 암호화 알고리즘과 MD5 해쉬 암호화 알고리즘을 기반으로 객체 지향적 코드를 설계 및 구현하도록 노력하였으며 MFC를 사용하여 간단한 UI를 적용하였다.

참고  
_MD5 : <https://www.ietf.org/rfc/rfc1321.txt>_  
_DES : <https://github.com/tarequeh/DES>_

-------------

2.개발 내용
-----------
### 2.1 개발 목표

  1. 객체 지향 프로그래밍 캡슐화, 상속, 다형성을 보장  
  	각 암호화 알고리즘을 클래스로 생성하여 캡슐화 하고 공통적으로 필요한 기능을 별로의 클래스로 제작한 뒤 상속받아 사용할 수 있도록 한다.

  2. 암호화 클래스를 간편하게 사용할 수 있도록 설계  
  	클래스 내부에 인풋 및 처리 함수 구현하고 암, 복호화 함수를 만들어 사용할 수 있도록 한다.

  3. 각 암호화 알고리즘에 대한 이해  
  	DES와 MD5 알고리즘의 동작 과정을 이해하고 알고리즘의 순서도를 작성한다. 알고리즘의 입력과 출력 결과를 세부적으로 작성한다.

  4. 프로그램의 세부적인 예외처리 구현  
  	알고리즘 및 UI 코드에서 에러가 발생하지 않도록 세부적인 예외처리를 한다.

--------

### 2.2 프로젝트 알고리즘 구현

![알고리즘 순서도]({{site.url}}/img/secretum17/1.png){: .center-image}

본 프로그램은 암호화 알고리즘에 따라서 파일을 암호화, 복호화 하는 프로그램으로서 위와 같은 동작으로 진행이 된다. 먼저 해당 파일을 어떠한 알고리즘을 통해서 암호화를 할 것인지 선택을 한다. 암호화는 블록 암호화 알고리즘인 DES와 해쉬 암호화 알고리즘인 MD5가 있다.

블록 암호화 알고리즘의 경우에는 key 파일이 요구되며 key 파일이 없을 경우 임시키 파일을 생성할 수 있도록 하였다. Encryption, Decryption을 수행할 수 있으며 결과는 암, 복호화 된 파일로 출력된다.

해쉬 암호화 알고리즘은 key 파일이 필요하지 않기 때문에 파일 선택 후 다음 작업으로 암호화를 진행한다. 복호화는 없으며 암호화된 결과 값은 string 형식으로 출력된다.

다음으로 본 프로젝트에서 사용된 두 알고리즘을 설명하고 어떠한 방식, 코드로 구현되었는지를 보인다.

----------

#### 1) DES algorithm

![DES-main-network, DES-key-schedule]({{site.url}}/img/secretum17/2.png){: .center-image}  

DES 알고리즘은 64bits의 평문(plaintext)를 Key를 이용하여 64bits의 암호문을 생성한다. Feistel Cipher 방식으로, 요약하자면 평문은 두 개로 나누어 반복되는 라운드 함수와 대응되는 라운드 키를 통해서 암호학적으로 강한 함수를 만드는 과정이다.

##### Main process

  1.	64 bit 평문 IP( Initial Permutation ) 수행  
  ![Initial permutation, IP table]({{site.url}}/img/secretum17/3.png){: .center-image}  
  초기의 64 bit의 평문을 치환하는 작업으로 bit의 순서를 미리 지정된 table에 맞추어 지정한다. 예를 들어 IP table에서 첫 인덱스의 58은 출력될 첫 번째 비트가 평문의 58번째 비트가 된다는 의미이다.

  2.	좌우 32 bit로 나뉘어 round 진행  
  치환 작업을 거친 64bit을 좌, 우 32bit 씩 나누어 주는 작업을 진행한다. 좌측 32 bit ro, 우측 32bit lo가 생성되며 ro는 각 라운드 마다 F 함수를 수행하게 된다.

  3.	ro 32 bit와 round key 48bit의 F 함수 수행  
  이 부분에서는 key 스케줄 작업을 거쳐 생성된 round key와 앞전의 나누어진 ro 32 bit가 F 함수를 수행하게 된다. F 함수에 관련된 내용과 키 스케줄에 관련된 내용은 아래에서 다루도록 하겠다.

  4.	ro 32bit와 lo 32bit의 XOR 연산, ro, lo 교체  
  F 함수를 수행한 ro는 lo 32bit와 XOR 연산( ro = ro XOR lo )을 수행한다. XOR 연산을 수행한 ro와 초기의 lo는 다음 라운드에 진입하기 전 교체작업을 한다. ro -> lo, lo -> ro의 작업을 수행하게 된다.

  5.	16 round 진행  
  바뀐 ro, lo는 다시 과정 2로 돌아가 16라운드의 작업을 진행한다.

  6.	IP^-1( Inverse Permutation )을 수행 후 암호문 출력  
 ![Final permutation ( IP^-1 ), IP^-1 table]({{site.url}}/img/secretum17/4.png){: .center-image}   
  초기의 치환 작업과 같은 방식으로 진행되며 IP^-1의 table에 맞게 값이 지정 된다. 다음과 같은 작업을 모두 마치고 나면 암호화된 평문이 출력된다.

-----------

##### Key schedulling

각 라운드 마다 서로 다른 round key가 필요로 하는데 이를 만드는 과정을 key 스케줄링 이라고 한다. 64bit의 key를 입력 받아서 16개의 round key를 만들어낸다.

  1.	PC 1 수행 ( Permuted Choice 1 ) 후 둘로 나눔  
![Permuted choice 1, PC 1 left, right]({{site.url}}/img/secretum17/5.png){: .center-image}  
  초기의 64bit key는 PC1을 수행하면서 left 28bit, right 28bit로 나누어진다. 테이블의 left, right는 어떠한 비트가 스케줄 과정에서 지정되는지를 보여준다. 64bit에서 58bit만을 선택하여 수행이 되는데 나머지 비트( 8, 16, 24, 32, 40, 48, 56, 64 )는 패리티 비트로 사용되도록 지정된다. 패리티 비트는 정보 전달 과정에서 오류가 생겼는지를 검사하기 위한 비트이다.

  2.	라운드 별 shift 연산 수행  
  ![Rotations in the key-schedule]({{site.url}}/img/secretum17/6.png){: .center-image}  
28bit의 left, right는 라운드 별로 각기 다른 shift 연산을 수행하게 된다. 위의 표는 라운드 별 shift 횟수이다.

  3.	PC 2 수행 ( Permuted Choice 2 ) 및 key 생성  
![Permuted choice 2, PC 2 table]({{site.url}}/img/secretum17/7.png){: .center-image}  
  PC 2는 shift 연산을 마친 56bit( left, right )에서 48bit를 선택하여 round key를 출력하는 구문이다. 이전의 과정과 비슷하게 테이블에서 해당 비트 값을 지정하여 출력한다. 16 개의 라운드를 거치며 16개의 key가 생성된다.

------------

##### F 함수  

![DES-f function]({{site.url}}/img/secretum17/8.png){: .center-image}  

1.	ro 32bit E( expension ) 함수 수행  
 ![Expansion function, Etable]({{site.url}}/img/secretum17/9.png){: .center-image}  
	E( ecpention )작업은 32 bit ro를 48bit로 늘려주는 확장 함수이다.

2.	48bit round key와 ro 48bit XOR 연산 수행  
	키 스케줄링 작업을 통해서 생성된 라운드 키와 E 함수를 수행한 ro가 XOR 연산을 수행한다.

3.	S-Box 작업 수행  
  ![S-Boxs]({{site.url}}/img/secretum17/10.png){: .center-image}  
	XOR 연산 후 48bit는 8개로 나누어져 S-Box 연산을 수행한다. 8개의 S-Box는 6bit의 입력을 4bit 출력으로 대체한다. 6bit의 입력이 주어지면 외부 2bit를 사용하여 행을 선택하고 내부의 4bit를 사용하여 4bit 출력을 찾는다. 예를 들어, 입력 “011010”은 외부 비트 “00” 및 내부 비트 “1101”을 갖는다. 해당 위치의 S-box의 값이 출력 되고 8개의 S-box에서 4bit가 출력되어 32bit의 값이 생성된다.

4.	P( Permutation ) 작업 수행 및 결과 값 출력  
  ![P permutation, P table]({{site.url}}/img/secretum17/11.PNG){: .center-image}  
	함수 P는 S-box의 결과값 32bit를 다시 한 번 섞어서 결과 값으로 출력한다.

-----------

#### 2) MD5 알고리즘

MD5는 128bit 암호화 해시 함수이며 주로 프로그램이나 파일이 원본 그대로인지 확인하는 무결성 검사 등에 사용된다. 임의의 길이의 메시지를 입력받아, 128bit짜리 고정 길이 출력값을 낸다. 알고리즘을 수행할 때는 512bit로 나누어 수행한다. 주의할 점은 Little-endian 연산을 한다는 점이다. 본 프로젝트는 rfc-1321 코드를 기반으로 작성되었다.

1.	Append Padding Bits  
	알고리즘이 512bit로 수행되기 때문에 512bit의 배수가 되도록 패딩 비트를 통해서 길이를 조절한다. 만약 정확하게 512bit의 메시지가 입력되더라도 512bit를 추가하여 1024가 되도록 길이를 맞춘다. 단 512bit 길이로 조절을 할 때 64bit를 남기고 패딩을 한다. 이 64bit는 2의 과정에서 추가하게 된다. 이 작업을 448 mod 512로 표현할 수 있다.

2.	Append Length  
	1의 과정을 수행하고 남은 64bit를 추가하는 작업이다. 패딩이 되기 전 원본 메시지의 길이를 입력하는 부분으로 2개의 32bit로 구성이 되어있다. little-endian 방식이기 때문에 낮은 바이트가 위쪽에 위치하는 모양을 취한다.

3.	Initialize MD Buffer  
 ![MD Buffer 초기화 값]({{site.url}}/img/secretum17/12.png){: .center-image}  
	MD5 알고리즘은 128bit의 출력 값을 가진다. MD buffer은 출력 값을 저장하고 있는 4개의 32bit 레지스터 이다. 해당 버퍼는 특정한 값으로 초기화 되어있고 이 역시 little-endian 형태로 저장되어 있다.  

4.	Process Message in 16-Word Blocks  
  ![단일 MD5 연산]({{site.url}}/img/secretum17/13.png){: .center-image}  
	실질적인 message digest를 진행하는 부분으로 16word( 512bit )단위로 수행된다. 메인 알고리즘은 A, B, C, D라고 이름이 붙은 128 bit state에 대하여 동작을 한다. 각 state는 다시 4개의 32bit(1 word)로 이루어져 있다. MD5에서는 위의 단일 연산을 64번 실행한다. 16개의 연산을 1개의 라운드로 묶어 총 4개의 라운드로 구성이 된다.  
  ![보조 함수 F 연산]({{site.url}}/img/secretum17/14.png){: .center-image}  
MD5를 수행하기 위해 필요한 요소로는 보조함수 F, 입력 메시지의 32비트 블록 M, K, 레프트 로테이션 <<<로 구성 되어있다. 그림의 Addition 기호는 모듈로 2^32 덧셈을 말한다. 함수 F는 각 라운드에서 사용하는 비 선형함수를 의미한다. 보조함수 F는 각 라운드마다 다르게 F, G, H, I로 정의되어 있다. 순서대로 XOR, 논리곱, 논리합, NOT 연산을 의미한다.  
  ![1 Round 의사 코드]({{site.url}}/img/secretum17/15.png){: .center-image}  
	각 라운드는 다음과 같은 구성으로 이루어져 있으며 보조함수의 종류만 달라진다. a, b, c, d가 state 블록이 이고 s는 left shift의 횟수를 의미한다. T는 라디안 값을 의미하는데 미리 지정된 값을 사용한다. X는 bit 단위의 블록을 연산을 위해 word 단위의 블록으로 변환한 것으로 X[16]으로 설명할 수 있다.

-------------

### 2.3 객체 지향적 코드 구현

![프로젝트 클래스 다이어그램]({{site.url}}/img/secretum17/16.png){: .center-image}  
클래스는 3개로 구성되어 있으며 두 암호화 알고리즘 MD5와 DES가 클래스로 구성되어있고 Wrapper 클래스를 상속받아서 두 클래스에서 공통적으로 처리하는 일을 수행하도록 하였다.

1) Wrapper class

래퍼 클래스는 두 암호화 클래스에서 공통적으로 처리하는 파일을 불러오는 일을 주로 수행하도록 하였다. 두 암호화 클래스가 Wrapper class를 상속받는 것으로 해당 기능을 사용할 수 있도록 하였다. 그리고 부가적으로 임시키를 발급해주는 기능을 추가하였다. 변수로는 input_file, output_file, key_file로 구성되어 있다.

Get_file() 함수는 암호화 할 파일을 가져오는 메소드로 fopen 과 같은 함수를 사용하여 작성되었다. Get_keyfile() 역시 동일한 작업을 하지만 .key 파일만을 받아들이게 하여 간단한 예외 처리를 해 주었다. Make_keyfile()은 사용자가 .key 파일이 없을 경우 임시키를 발급받을 수 있도록 rand함수를 사용하여 제작한 함수이다.

wrapper의 상속으로 md5 클래스에 사용하지 않는 변수가 상속되는 문제가 있는데 조금 더 객체지향 적인 코드 수정이 필요하다.

2) MD5

MD5 클래스는 message digest를 위해서 필요한 변수 state, count, buffer, PADDING이 존재하며 자료형인 bit32, byte는 자료형의 크기를 직관적으로 보기 위해서 정의하였다.

Encode(), Decode() 함수는 알고리즘을 수행하면서 자료형을 원활하게 바꾸기 위해서 정의 되었다. Encode()의 경우 32bit input을 1byte의 output으로 변환하는 함수이고 Decode()는 1byte input을 32bits output으로 변환하는 함수이다. Encode()의 경우에는 little-endian 방식으로 작동하는 알고리즘의 특성에 맞도록 변환해주는 구문이 포함되어 있다.

MD5_init()의 경우 변수들의 초기화 작업을 수행하고 실직적인 알고리즘은 MD5_update()와 MD5_final()에서 동작한다. MD5 process는 Step1 ~ 5까지 순서대로 진행되는 반면 실질적인 코드 구현 순서는 조금 다르다. Step1 Append Padding Bits와 Step2 Append Length는 MD5_final() 함수에서 동작하며 Step3과 Step4의 과정을 수행한 뒤 진행한다. MD5_transform() 함수에서는 Step4 Process message in 16-word Block가 수행되며 실질적인 main 알고리즘이 되겠다.

3) DES

DES 클래스는 크게 key 스케줄링을 주관하는 부분과 메시지를 암호화 하는 부분으로 이루어진다. 치환 작업이 많은 알고리즘으로 치환을 위한 테이블을 변수로 지정하여 관리하였다. key_ip, sub_key_permutation, message_ip, message_expension, message_final_ip와 같은 table이 위치하고 있다.

Generate_sub_key() 함수는 사용자에게 64bit key를 입력 받아 16개의 48bit round key를 만드는 작업을 수행한다. PC1, PC2, shift 연산 작업을 수행한다. Set_DES() 에서는 암, 복호화를 위한 변수들을 초기화 하는 작업을 한다.

process_message는 8byte의 원본 messeage_piece와 key_set을 입력 받아서 암호화 또는 복호화 된 메시지를 출력하게 된다. DES_encode(), DES_decode() 함수는 Wrapper 클래스에서 파일을 입력 받고 해당 파일을 8 byte 씩 읽어 들이면서 암호화, 복호화 하는 작업을 수행한다.

----------

### 2.4 UI 구성

![프로그램 UI DES, MD5]({{site.url}}/img/secretum17/17.PNG){: .center-image}  
본 프로그램은 MFC를 사용하여 UI를 구성하였다. 기본적으로 파일에 대한 암호화를 수행하여서 암호화 또는 복호화 할 파일을 입력받을 창이 존재한다. DES 알고리즘은 대칭키 기반으로 동작하기 때문에 key file을 선택할 수 있도록 박스를 구성하였고 그 안에 임시키 파일을 생성할 수 있는 버튼을 마련하였다. 암호화, 복호화 된 결과물은 파일로 출력이 된다.

MD5의 경우에 key file을 필요로 하지 않기 때문에 오류 발생을 막기 위해 예외처리를 하였고 Decryption 역시 버튼을 비활성화 시켜 두었다. DES와 다르게 출력 결과는 메시지박스에 128bit의 문자열로 출력이 되도록 하였다.
