function solutionPart1(n, data)
  implicit none
  integer :: n, data(n), solutionPart1
  solutionPart1=count(data(2:n).gt.data(1:n-1))
end function

function solutionPart2(n, data)
  implicit none
  integer :: n, data(n), solutionPart2, sliding(n-2)
  sliding=data(1:n-2)+data(2:n-1)+data(3:n)
  solutionPart2=count(sliding(2:n-2).gt.sliding(1:n-3))
end function

program aoc
  implicit none
  integer, allocatable :: data(:)
  integer :: n, stat, x
  character(len=6) :: part
  integer :: solutionPart1, solutionPart2

  open(20,file='input.txt')
  n=-1
  stat=0
  do while(stat == 0)
     n=n+1
     read(20,*,iostat=stat)x
  enddo
  allocate(data(n))
  rewind(20)
  read(20,*)data
  close(20)

  call get_environment_variable('part', part)
  if (trim(part).eq.'part1'.or.trim(part).eq.'') then
    print *, solutionPart1(n, data)
  else if (trim(part).eq.'part2') then
    print *, solutionPart2(n, data)
  else
    print *, 'Unknown part '//part
  end if
end program aoc