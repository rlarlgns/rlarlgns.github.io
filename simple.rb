
require 'msf/core'  # mixin

class MetasploitModule < Msf::Exploit::Remote   # 클래스 상속 관계
  Rank = NormalRanking

  def initialize(info={})
    super(update_info(info,
      'Name'           => "[Vendor] [Software] [Root Cause] [Vulnerability type]",
      'Description'    => %q{ Say something that the user might need to know },
      'License'        => MSF_LICENSE,
      'Author'         => [ 'Name' ],
      'References'     => [ [ 'URL', '' ], [ 'CVE', '' ] ],
      'Platform'       => 'win',
      'Targets'        =>
        [[ 'System or software version',
          { 'Ret' => 0x41414141 # 취약점의 target.ret
            }]],
      'Payload'        => { 'BadChars' => "\x00" },
      'Privileged'     => false,
      'DisclosureDate' => "",
      'DefaultTarget'  => 0) )
  end

  def check  # For the check command
  end

  def exploit # Main function
  end
end




require 'msf/core'  # mixin

class MetasploitModule < Msf::Auxiliary   # 클래스 상속 관계

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Module name',
      'Description'    => %q{
        Say something that the user might want to know.
      },
      'Author'         => [ 'Name' ],
      'License'        => MSF_LICENSE
    ))
  end

  def run
    # Main function
  end

end
