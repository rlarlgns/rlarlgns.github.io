---
layout: post
title: "Window System Programming 1"
description: "[study] Unicode, 메모리, 프로세스, 스레드"
date: 2017-07-24
tags: [study, Unicode, 메모리, 프로세스, 스레드]
comments: true
share: true
---

교육 일자 : 2017. 07. 17 ~ 21  
교육 장소 : 삼성 멀티 캠퍼스  
교육 과정 : 고급 개발자를 위한 Window System Programming  

# 1일차  

교육내용 : Unicode, 메모리, 프로세스, 스레드  
Source code : <https://github.com/rlarlgns/study/tree/master/Window%20System%20Programming/Day_1>  

### 문자코드  
 - SBCS( Single Byte Character Set ), DBCS( Double Byte Character Set )
 - MBCS( Multi Byte Character Set ) : ANCI Code, WBCS( Wide Byte Character Set ) : UNI Code
 - MBCS는 SBCS, DBCS를 같이 사용하는 구조이며 문자열의 끝에 “\0” 문자를 포함한다.
 - WBCS는 모든 문자가 2byte로 구성되며 SBCS에서 1byte로 표현되는 문자의 경우 “\0”문자를 추가하여 사용한다. 문자열의 끝을 “\0\0”로 구분한다.
 - Ex) “ABC” -> ‘A \0’ ‘B \0’ ‘C \0’ ‘ \0 \0’
 - 문자열의 구성이 다르기 때문에 별도의 문자열 처리 함수를 사용한다.
 - Ex) printf( ) -> wprintf( )

### Win16 메모리 구조  
 - Win16의 메모리 구조를 입체적 구조라고 부르는데 이는 20bit의 메모리와 16bit의 레지스터를 사용하는 구조에서 효율적으로 메모리를 사용하기 위해 offset을 사용함으로써 만들어진 구조이다.
 - 가장 큰 특징으로 모든 프로그램이 같은 주소 공간을 사용한다는 것이다.
 - 이러한 구조의 장점으로는 서로 다른 프로세스에 포인터를 통해 쉽게 접근이 가능하다는 것이고 단점은 쉽게 접근할 수 있기 때문에 프로세스들 간에 충돌로 인한 오류 잘 일어난다는 것이다.

### Win32 메모리 구조  
 - 32bit 레지스터를 통해서 최대 4G의 메모리를 지원한다.
 - 주소 공간을 분리하여 각 프로세스 마다 4G의 메모리를 할당해 준다. ( 가상 메모리 사용 )

### 가상 메모리  
 - 물리적인 메모리가 부족하기 때문에 하드디스크를 메모리처럼 사용하는 기법이다.
 - 운영체제 단에서 페이지 테이블을 통해서 가상 메모리의 주소를 관리하여 사용함.
 - C 런타임 함수 : malloc / free
 - C++ 객체의 동적 할당 연산자 : new / delete
 - Win32 가상 메모리 함수 : VirtualAlloc / VirtualFree
 - Win32의 가상 주소 공간은 페이지 단위로 구분하여 지나치게 메모리가 조각나는 것을 방지한다.

### 프로세스
 - 주소공간과 파일, 메모리, 스레드를 소유한다.
 - CreateProcess() : 프로세스를 생성 후 바로 리턴
 - OpenProcess() : 이미 실행된 프로세스의 핸들을 얻어옴
 - ExitProcess() : 프로세스 종료 ( 스스로 )
 - TerminateProcess() : 프로세스 강제 종료
 - EnumProcess() : 현재 실행중인 프로세스들의 ID를 배열로 로드 ( API를 이용 )
 - CreateToolhelp32Snapshot() : 운영체제를 통해 실행중인 프로세스를 로드

### 커널 오브젝트
 - 오브젝트 : 시스템 리소스에 대한 정보를 가지는 데이터 구조체
 - 핸들 : 객체 관리를 위한 32bit 정수 값
 - User, GDI 모듈 : 한 오브젝트에 하나의 핸들을 가짐, 윈도우와 그래픽 관리
 - 커널 모듈 : 하나의 오브젝트에 여러 개의 핸들 가능, 커널 관리
 - 커널 모듈의 함수는 CreateOOO의 구조를 가짐 ex) CreateProcess(), CreateFile()
 - 커널 오브젝트는 프로세스에 한정적임 -> 오브젝트를 생성한 프로세스만이 이를 제어할 수 있음 만약 다른 프로세스에서 이 오브젝트를 제어하고자 한다면 커널 오브젝트의 ID 값으로부터 핸들을 다시 얻어야 한다.

# 1일차 실습  
![1일차 실습]({{site.url}}/img/Window/Day1_1.jpg){: .center-image}  

### 실습 : CreateProcess
 - WinExec, CreateProcess, Exit Process, Terminate Process 함수 실습  
![1일차 실습]({{site.url}}/img/Window/Day1_2.jpg){: .center-image}  
<script src="https://gist.github.com/rlarlgns/25a9f366379bea460653db2ccd84f097.js"></script>  

### 실습 : Process List
 - 현재 실행중인 프로세스를 나열
 - EnumProcess()를 사용한 API를 이용한 방법, SnapShot()를 사용한 운영체제를 통한 방법 실습
 - 핸들 획득 후 프로세스를 Terminate 실습  
![1일차 실습]({{site.url}}/img/Window/Day1_3.jpg){: .center-image}
<script src="https://gist.github.com/rlarlgns/0f1b01650ea712a69553dd7f9c103cef.js"></script>  

### 실습 : Process AB
![1일차 실습]({{site.url}}/img/Window/Day1_4.jpg){: .center-image}  
<script src="https://gist.github.com/rlarlgns/ef10ca13f3cfbd04ab5db8f19c941a3a.js"></script>  
