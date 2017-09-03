---
layout: post
title: "Window System Programming 4"
description: "[STUDY] 파일 매핑, 동기 비동기 I/O "
date: 2017-07-27
tags: [study, 파일 매핑, 비동기 I/O ]
comments: true
share: true
---

교육 일자 : 2017. 07. 17 ~ 21  
교육 장소 : 삼성 멀티 캠퍼스  
교육 과정 : 고급 개발자를 위한 Window System Programming  

# 4일차

교육내용 : 파일 매핑, 동기 비동기 I/O
Source code : <https://github.com/rlarlgns/study/tree/master/Window%20System%20Programming/Day_4>

### 동기, 비동기 I/O
 - 비동기 I/O는 스레드를 생성한 것처럼 운영체제가 알아서 파일 입출력을 처리한 다음 완료되었을 때 알려주는 이벤트 콜백 방식으로 이루어지며 중첩되서 수행된다는 의미로 Overlapped IO 라고 부르기도 한다.
 - CreateFile로 핸들을 구해서 동기, 비동기 I/O를 수행한다.
 - ReadFile, WriteFile 은 마지막 lpOverlapped 인자를 통해 동기 비동기로 수행될 수 있다.
 - ReadFileEx, WriteFileEx 는 추후에 만들어진 비동기 전용 함수이다.
 - 비동기 함수의 완료 통지를 확인 하는 방법으로는 디바이스 커널 객체의 시그널링, 이벤트 커널 객체의 시그널링, 얼러터블 I/O ( 비동기 전용 함수 )가 있다.
 - IOCP (I/O Completion Port )는 I/O 요청을 수행할 스레드를 미리 만들어 필요할 때만 활성화 하여 처리하므로 성능이 우수한 기법이다.

### 파일 매핑( MMF )
 - 하드디스크에 존재하는 파일의 내용을 프로세스의 주소공간에 연결(map)하는 기법
 - 가상 주소 공간에 파일을 연결하고, 그 포인터를 사용해서 파일을 관리
 - 파일 입출력에 필요한 자원을 아낄 수 있고 로딩속도가 빠르며 가상메모리를 절약
 - 파일 액세스 : 파일 매핑 오브젝트를 만들고 프로세스의 가상메모리의 주소공간에 연결하여 메모리처럼 사용한다.
 - CreateFileMapping() : 오브젝트 생성
 - MapViewOfFile() : 프로세스의 가상메모리 주소공간에 연결
 - UnmapViewOfFile() : 파일 뷰를 닫음
 - 프로세스 간에 메모리 공유가 가능하다. -> 하나의 파일 매핑 오브젝트에 여러 개의 뷰를 열거나 다수의 프로세스가 같은 이름의 파일 매핑 오브젝트를 접근

# 4일차 실습

![4일차 실습]({{site.url}}/img/Window/Day4_1.png){: .center-image}  

### 실습 : MemFile  
 - 파일 매핑을 통해서 하드디스크에 있는 파일의 내용을 읽고 쓰는 실습이다.
 - 먼저 파일의 핸들을 구하여 CreateFileMapping의 인자로 주어 파일 매핑 오브젝트를 만든다. 이는 디스크 상의 파일을 가상 주소 공간에 연결하는 정보이다.
 - 다음으로 파일 뷰를 생성하여 그 포인터 값으로 파일을 제어할 수 있다.
 - 작업을 마친 후에 UnmapViewOfFile() 함수로 파일 뷰를 닫아 준다.

![4일차 실습]({{site.url}}/img/Window/Day4_2.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/015f92c7d275fecf4e0f0b66114c06ca.js"></script>

### 실습 : MemShare
 - 프로세스 간에 파일을 매핑하여 한쪽에서 입력한 텍스트가 다른 쪽에도 입력되도록 하는 실습
 - 가상 메모리의 한 지점을 파일 매핑 오브젝트와 연결하여 두 프로세스가 같은 가상 메모리를 가리키도록 한다.

![4일차 실습]({{site.url}}/img/Window/Day4_3.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/c2d6492a5d111810a403315cf06df6be.js"></script>

### 실습 : MyAsyncIO
 - 비동기 함수를 이용해서 파일을 읽고 쓰는 실습이며 비동기를 이용해 큰 데이터의 파일을 처리 해본다.
 - 비동기 작업을 하기위해 OVERLAPPED 구조체를 사용하여 ReadFile, WriteFile에 비동기 인자를 주어 사용한다.
 - ReadFileEx, WriteFileEx 는 비동기 전용함수로 콜백함수를 만들어 사용한다.

<script src="https://gist.github.com/rlarlgns/e03bff83ddcc5a9b45743d2a1862365f.js"></script>

### 실습 : BigFile I/O

<script src="https://gist.github.com/rlarlgns/b6d5160935e6a35c65e5bbd95060808b.js"></script>
