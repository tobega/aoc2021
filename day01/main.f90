function solutionPart1()
  implicit none
  integer :: a, b, solutionPart1
  solutionPart1=0
  read(20,*,end=900) a
  do while(.true.)
    read(20,*,end=900) b
    if (b.gt.a) then
      solutionPart1=solutionPart1+1
    end if
    read(20,*,end=900) a
    if (a.gt.b) then
      solutionPart1=solutionPart1+1
    end if
  end do
900 return
end function

function solutionPart2()
  implicit none
  integer :: a, b, c, d, solutionPart2
  solutionPart2=0
  read(20,*,end=990) a
  read(20,*,end=990) b
  read(20,*,end=990) c
  do while(.true.)
    read(20,*,end=990) d
    if (d.gt.a) then
      solutionPart2=solutionPart2+1
    end if
    read(20,*,end=990) a
    if (a.gt.b) then
      solutionPart2=solutionPart2+1
    end if
    read(20,*,end=990) b
    if (b.gt.c) then
      solutionPart2=solutionPart2+1
    end if
    read(20,*,end=990) c
    if (c.gt.d) then
      solutionPart2=solutionPart2+1
    end if
  end do
990 return
end function

program aoc
  implicit none
  character(len=6) :: part
  integer :: solutionPart1, solutionPart2

  open(20,file='input.txt')

  call get_environment_variable('part', part)
  if (trim(part).eq.'part1'.or.trim(part).eq.'') then
    print *, solutionPart1()
  else if (trim(part).eq.'part2') then
    print *, solutionPart2()
  else
    print *, 'Unknown part '//part
  end if
  close(20)
end program aoc