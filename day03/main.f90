block data consts
  common powers(12)
  integer :: powers = (/(2**(12-i), I=1,12)/)
end block data consts

function solutionPart1()
  implicit none
  common powers(12)
  integer powers
  integer :: solutionPart1, counts(12), bits(12), n, i
  n = 0
  counts = 0
  do while(.true.)
    read(20,'(12I1)',end=900) bits
    n = n+1
    counts = counts+bits
  end do
900 solutionPart1=sum(pack(powers, counts.GT.n/2))*sum(pack(powers,counts.LE.n/2))
end function

function solutionPart2()
  implicit none
  common powers(12)
  integer powers
  integer :: n, i, j, stat, solutionPart2, ones, ogr, csr
  integer, allocatable :: data(:,:), selected(:)
  n=-1
  stat=0
  do while(stat == 0)
     n=n+1
     read(20,'(I1)',iostat=stat)i
  enddo
  allocate(data(12,n))
  rewind(20)
  read(20, '(12I1)') data
  selected=(/(i,i=1,n)/)
  do i=1,12
    ones=sum(data(i,selected))
    if (ones.ge.(size(selected)+1)/2) then
      selected=pack(selected, data(i,selected).EQ.1)
    else
      selected=pack(selected, data(i,selected).EQ.0)
    end if
    if (size(selected).le.1) then
      exit
    end if
  end do
  ogr=sum(pack(powers,data(1:12,selected(1)).EQ.1))
  selected=(/(i,i=1,n)/)
  do i=1,12
    ones=sum(data(i,selected))
    if (ones.lt.(size(selected)+1)/2) then
      selected=pack(selected, data(i,selected).EQ.1)
    else
      selected=pack(selected, data(i,selected).EQ.0)
    end if
    if (size(selected).le.1) then
      exit
    end if
  end do
  csr=sum(pack(powers,data(1:12,selected(1)).EQ.1))
  solutionPart2=ogr*csr
end function

program aoc
  implicit none
  character(len=6) :: part
  integer :: solutionPart1, solutionPart2, n

  open(20,file='input.txt')

  call get_environment_variable('part', part)
  if (trim(part).eq.'part1'.or.trim(part).eq.'') then
    n = solutionPart1()
    print *, n
  else if (trim(part).eq.'part2') then
    n = solutionPart2()
    print *, n
  else
    print *, 'Unknown part '//part
  end if
  close(20)
end program aoc