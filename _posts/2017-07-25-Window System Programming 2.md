---
layout: post
title: "Window System Programming 2"
description: "[study] 스레드, TLS, 동기화"
date: 2017-07-25
tags: [study, 스레드, TLS, 동기화]
comments: true
share: true
---

교육 일자 : 2017. 07. 17 ~ 21  
교육 장소 : 삼성 멀티 캠퍼스  
교육 과정 : 고급 개발자를 위한 Window System Programming  

# 2일차

교육내용 : 스레드, TLS, 동기화

### 스레드
 - 프로세스 내에 존재하는 실행 흐름
 - 프로세스 생성 시 하나의 주 스레드( Primary Thread )가 생성 됨
 - 스레드를 이용해 다중 작업을 수행 시 운영체제가 스레드별로 CPU를 할당한다.
 - 같은 프로세스 내의 스레드는 주소공간, 전역변수, 코드를 공유
 - 스레드 생성 함수 : CreateThread() - Win32, \_beginThread/Ex() - C Runtime, AfxBeginThread() - MFC  
 - 주 스레드의 작업 스레드 종료 여부 조사 : GetExitCodeThread()
 - 스레드 강제 종료 : ExitThread() - 스스로 종료, TerminateThread() - 강제 종료
 - 스레드 중지 : SuspendThread() - 중지, ResumeThread() - 재개

### 멀티 스레드
 - 스케줄링 : 다수 개의 스레드를 어떤 순서로 얼마만큼 실행할지를 결정하는 정책
 - 우선순위( Priority ) : 스레드간의 우선순위를 정해 더 많은 CPU 시간 할당
 - 문제점 : 공유자원 보호 문제, 무한대기, 호출순서 예측 불가, 디버깅 어려움
 - 해결책 : 1. 작업 복사본, 2. 호출 순서, 3. 재진입 가능성
 - 작업복사본 : 두 스레드가 동일한 자원을 접근할 때 의도치 않은 값이 나올 수 있음
 - 호출 순서 : 스레드의 시작과 종료를 예측할 수 없기 때문에 순서가 있는 작업을 스레드로 분리해서는 안 됨, 꼭 필요하다면 뮤텍스, 세마포어, 이벤트 등을 사용
 - 재진입 가능성 : 스레드에서 전역, 정적 변수를 사용하면 위험, TLS를 사용하여 해결
 - C 런타임 라이브러리 주의점 : C언어는 멀티스레드 개념이 도입되기 전의 언어이기 때문에 몇몇 전역변수와, 정적변수에서 오류가 발생할 수 있다.
 - 해결책 : 멀티스레드 용으로 사용가능한 C라이브러리를 사용한다.

### TLS( 스레드 지역 저장소 )
 - 스레드에 개별적으로 생성되는 지역 저장소, 스레드가 만들어 질 때 시스템에서 개별적으로 LPVOID형 배열을 할당
 - 정적 TLS : \__declspec( thread )
 - 동적 TLS : TlsAlloc(), TlsFree()
 - TlsAlloc() : TLS에 남아있는 여유 슬롯의 인덱스를 리턴, 할당된 인덱스의 슬롯을 0으로 리셋, 리셋 값은 다른 스레드도 참조하기 위해서 전역으로 따로 저장함
 - TlsSetValue(), TlsGetValue() : TLS에 값을 저장하거나 읽을 때 사용
 - TlsFree() : 인덱스 사용 후 반납

### 동기화
 - 멀티스레드 프로그래밍의 경우 경쟁상태( Race Condition )이나 교착상태( Deadlock )에 빠지기 쉽다.
 - 동기화는 스레드 간에 실행순서와 통신을 제어하기 위한 기술이다.
 - 유저 모드의 동기화 – 크리티컬 섹션
 - 크리티컬 섹션은 임계영역을 만들어서 동기화, 운영체제에서 지원하며 속도가 빠름 단, 동일한 프로세스 내에서만 동기화 가능
 - 신호화 비신호 상태를 가지는 동기화에 사용되는 커널 객체를 동기화 객체라고 한다.
 - 동기화 객체를 통해 프로세스들 사이의 동기화가 가능
 - 대기함수란 스레드의 신호여부에 따라 스레드를 대기, 재개 시키는 함수이다.
 - WaitForSingleObject(), WaitForMultipleObjects() - 커널 모드 동기화
 - 커널 모드 동기화 객체 – 뮤텍스, 세마포어, 이벤트
 - 뮤텍스 : 하나의 자원을 하나의 스레드만이 소유하도록 관리, 크리티컬 섹션과 비슷하나 프로세스 간에도 사용가능
 - 뮤텍스 함수 – CreateMutex(), OpenMutex(), ReleaseMutex()
 - 세마포어 : 여러 개의 자원을 관리하는 동기화 객체
 - 세마포어 함수 – CreateSemaphore(), OpenSemaphore(), ReleaseSemaphore()
 - 이벤트 : 스레드 간에 통신을 위해서 사용하는 객체로 이벤트를 감지한다. 대기함수를 사용하지 않고 임의적으로 상태 설정이 가능하다.
 - 이벤트 함수 – SetEvent(), ResetEvent(), CreateEvent(), OpenEvent()
 - 자동리셋, 수동리셋 이벤트 : 둘의 차이는 대기 상태 종료 후 자동으로 바뀌는지 ResetEvent를 사용해서 바꾸는지의 차이가 있다. 자동리셋의 경우 단 한번 신호를 보내며 하나의 이벤트를 하나의 스레드에 사용할 때 유용하다.

# 2일차 실습

### 실습 : BackThread
 - 가상의 Air에서 전송받은 데이터를 가공하여 저장하는 기능을 수행하는 예제
 - OnTimer 함수로 100개의 데이터를 입력받고 모두 받을 경우 CalcThread를 생성하는데 발생하는 오류를 처리하며 실습
 - arData를 두 스레드에서 사용하면서 값이 변조되기 때문에 복사본(arCopy)를 생성
 - GetAddNum()에서 데이터에 일정한 규칙으로 더해주는데 지역변수으로 처리할 경우 규칙에 어긋나게 됨, 따라서 정적변수 또는 TLS를 사용하여 처리를 한다.
 - TLS는 다이얼로그가 생성되고 파괴될 때 할당하고 반환한다.

![2일차 실습]({{site.url}}/img/Window/Day2_1.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/2e9e9d781dc7c46ebee606b6fb1fecd1.js"></script>  

### 실습 : Race
 - 두 개의 스레드가 자원을 공유하면서 발생할 수 있는 오류를 크리티컬 섹션, 뮤텍스를 사용해 처리하는 실습이다.
 - 각 스레드는 공유자원 X의 값에 해당하는 위치에 글씨를 출력하는데 의도하지 않은 위치에 값이 출력되는 경우가 발생한다.
 - 공유자원을 사용하는 위치에 임계영역을 생성하거나 대기함수로 스레드를 대기시켜 해결할 수 있다.
 - 수행을 마친 스레드는 “수행 완료” 메시지 박스를 나타내는데 스레드가 CPU의 자원을 할당받는 정도는 계속 바뀌기 때문에 실행할 때마다 결과가 다르게 나온다.

![2일차 실습]({{site.url}}/img/Window/Day2_2.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/9ab1aa32695461d26041316e897f9e77.js"></script>

### 실습 : SemDown
 - 파일을 다운로드 받는 상황을 가정한 실습으로 동시에 다운로드 받는 스레드의 개수는 제어하고자 한다.
 - 클릭 시 계속해서 스레드를 생성하며 다운로드를 수행한다. 최대 동시에 3개까지 다운로드 작업을 수행하도록 세마포어를 사용해서 제어하였다.

![2일차 실습]({{site.url}}/img/Window/Day2_3.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/664d18e4d95b56bae8f8d75488e77b19.js"></script>  

### 실습 : BackEvent
 - 자동, 수동 이벤트를 사용해서 스레드를 제어하는 실습이다.
 - 왼쪽 버튼 클릭 이벤트는 자동 이벤트를 사용해서 하나의 스레드를 돌렸다.
 - 오른쪽 버튼 클릭은 수동 이벤트를 사용하였고 첫 스레드에서 이벤트가 Set 될 때까지 나머지 스레드는 대기하다가 작업을 수행한다.

![2일차 실습]({{site.url}}/img/Window/Day2_4.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/c51c37e517cdb432c7e1c2f49192ad5e.js"></script>  
  
