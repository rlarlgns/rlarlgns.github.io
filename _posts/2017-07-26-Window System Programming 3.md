---
layout: post
title: "Window System Programming 3"
description: "[STUDY] 스레드, TLS, 동기화"
date: 2017-07-26
tags: [study, 스레드, TLS, 동기화]
comments: true
share: true
---

교육 일자 : 2017. 07. 17 ~ 21  
교육 장소 : 삼성 멀티 캠퍼스  
교육 과정 : 고급 개발자를 위한 Window System Programming  

# 3일차

교육내용 : 병렬 프로그래밍, IPC, 파이프  
Source code : <https://github.com/rlarlgns/study/tree/master/Window%20System%20Programming/Day_3>

### 병렬 프로그래밍
 - 병렬성 : 연산들이 동시적으로 실행되는 것에 중점, 연관성이 없는 작업을 수행
 - 병렬 프로그래밍 모델 - SIMD( 명령어 수준 ), 공유 메모리 병렬 프로그래밍 모델, 메시지 패싱 병렬 프로그래밍 모델
 - SIMD : 한 번의 연산으로 여러개의 데이터 처리 ex) cpu
 - 공유 메모리 병렬 프로그래밍 모델 : 멀티 스레드로 데이터를 처리하는 모델 ex) Multithreading, OpenMP, CUDA
 - 메시지 패싱 병렬 프로그래밍 : 여러 개의 PC를 메시지로 통신하여 대용량의 데이터 처리 ex) 분산 컴퓨팅, 그리드 컴퓨팅

### OpenMP
 - C, c++, FORTRAN 언어에서 사용 가능한 병렬 라이브러리
 - opm.h 를 추가하고 visual의 경우 프로젝트 설정에서 OpenMP 지원을 ‘예’로 설정
 - #pragma omg parallel - 병렬처리 영역을 지정
 - #pragma omg parallel num_threads( ) - 생성할 스레드의 개수를 제한
 - #pragma omg parallel private( 변수 ) - 변수를 TLS에 담음

### IPC
 - 프로세스 간의 통신 방법
 - Win32 환경의 IPC : 메세지, 클립보드, DDE, 메일슬롯, 파이프, 파일 매핑, 윈속, RPC, COM

### 파이프
 - 두 프로세스 간에 정보를 전달하는 통로로 연속적인 바이트 스트림을 교환할 때 많이 사용
 - 파이프 종류 : Anonymous Pipe, Named Pipe
 - Named Pipe : 문자열로 된 이름을 가짐
 - 파이프를 최초로 만든 프로세스가 파이프 서버가 되며 파이프 인스턴스에 접속하는 프로세스가 파이프 클라이언트가 된다.
 - 파이프 서버 : CreateNamedPipe() - 파이프 생성, ConnectNamedPipe() - 클라이언트 접속 대기, DisconnectNamedPipe() - 접속 해제
 - 파이프 클라이언트 : WaitNamedPipe() - 서버가 생성한 파이프를 사용할 때까지 대기, CreateFile() - 파일 파이프 생성

# 3일차 실습

### 실습 : OpenMP  
 - 병렬 라이브러리인 OpenMP를 사용해서 화면에 작업 중인 스레드를 출력하는 실습
 - OpenMP를 사용하기 위한 설정을 마치고 작성
 - omp_get_max_threads() 함수로 core의 개수를 구하고 그 수만큼 스레드 생성
 - 스레드의 번호를 구해서 출력하고 barriar 구문으로 모든 스레드가 종료된 후 스레드 개수 출력

![3일차 실습]({{site.url}}/img/Window/Day3_1.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/b73a1e006bbbd7995efdcea340ed39d5.js"></script>  

### 실습 : NamedPipe
 - NamePipe를 사용해서 서버와 클라이언트를 만든 후 서버에서 클라이언트로 문자열을 전송하는 실습
 - 서버에서는 파이프를 생성하고 클라이언트 접속을 대기
 - 서버에서 한번 접속을 받고 끝나기 때문에 여러 클라언트를 받을 수 없음
 - 클라이언트는 스레드를 사용하지 않고 무한루프로 입력을 기다려서 응답없음에 빠짐

![3일차 실습]({{site.url}}/img/Window/Day3_2.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/0a0af29fecdada0eb0ec6c75e230b485.js"></script>  

### 실습 : MultiPipe
 - NamedPipe를 이용해서 클라이언트와 연결하여 데이터를 주고받고 다수의 클라이언트와 연결하기 위해 스레드를 사용하였다.
 - 서버에서는 사용자를 계속해서 받는 ListenThread가 있고 여기에서 각 사용자마다 데이터를 보내주기 위한 ClientThread가 접속 받을 때마다 생성된다.
 - 클라이언트의 경우 primary thread를 제외한 ConnectThread를 하나 생성하여 서버의 파이프를 기다리는 작업을 수행하게 하였다.

![3일차 실습]({{site.url}}/img/Window/Day3_3.png){: .center-image}  
<script src="https://gist.github.com/rlarlgns/381d15451a8dc8a0f250d61491b282f4.js"></script>  
