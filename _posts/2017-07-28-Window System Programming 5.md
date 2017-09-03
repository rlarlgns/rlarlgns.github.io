---
layout: post
title: "Window System Programming 5"
description: "[STUDY] DLL, 예외처리 "
date: 2017-07-28
tags: [study, DLL, 예외처리 ]
comments: true
share: true
---

교육 일자 : 2017. 07. 17 ~ 21  
교육 장소 : 삼성 멀티 캠퍼스  
교육 과정 : 고급 개발자를 위한 Window System Programming  

# 5일차

교육내용 : DLL, 예외처리
Source code : <https://github.com/rlarlgns/study/tree/master/Window%20System%20Programming/Day_5>

### DLL (Dynamic Link Library)
 - 정적연결은 컴파일 시에 함수가 실행 파일에 연결되며 실행 파일에 함수의 코드가 복사되는 구조이다. 실행파일의 크기가 커지지만 단독으로 실행할 수 있는 파일이 된다.
 - 동적연결은 실행 시에 함수가 실행 파일에 연결되는 구조로 호출할 함수의 정보만 포함된다. 실행 파일의 크기가 작고 실행 시에 반드시 DLL이 있어야 한다.
 - DLL은 프로그램의 크기가 작고 로딩 속도가 빠르며 한 코드를 여러 프로그램이 동시에 사용하기 때문에 메모리가 절약된다.
 - DLL을 사용하여 혼합 프로그래밍이 가능. UI 개발, 시스템 또는 빠른 속도 요하는 부분 따로 제작 한다.
 - declspec : 함수에 대한 정보를 제공하는 선언문
 - ____extern “C” : C++의 네임 맹글링을 막아서 C 형식의 함수 정보를 공개
 - #pragma comment (lib, "mydll.lib") : 해당 함수가 어느 DLL에 있는지를 밝힌다.

### 파일 매핑( MMF )
 - 하드디스크에 존재하는 파일의 내용을 프로세스의 주소공간에 연결(map)하는 기법
 - 가상 주소 공간에 파일을 연결하고, 그 포인터를 사용해서 파일을 관리
 - 파일 입출력에 필요한 자원을 아낄 수 있고 로딩속도가 빠르며 가상메모리를 절약
 - 파일 액세스 : 파일 매핑 오브젝트를 만들고 프로세스의 가상메모리의 주소공간에 연결하여 메모리처럼 사용한다.
 - CreateFileMapping() : 오브젝트 생성
 - MapViewOfFile() : 프로세스의 가상메모리 주소공간에 연결
 - UnmapViewOfFile() : 파일 뷰를 닫음
 - 프로세스 간에 메모리 공유가 가능하다. -> 하나의 파일 매핑 오브젝트에 여러 개의 뷰를 열거나 다수의 프로세스가 같은 이름의 파일 매핑 오브젝트를 접근

# 5일차 실습

### 실습 : MyDll  
 - DLL을 제작하고 사용하는 실습이다.
 - DLL 프로젝트를 만들어 함수를 작성하여 컴파일하면 .dll , .lib 파일이 생성된다.
 - (import) 구문이 포함된 해더를 작성하여 사용할 프로젝트에 위의 두 파일과 같이 첨부한다.

![5일차 실습]({{site.url}}/img/Window/Day5_1.png){: .center-image}
<script src="https://gist.github.com/rlarlgns/19612490aac2538cc796f3535b752858.js"></script>
