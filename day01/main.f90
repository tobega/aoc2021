function solutionPart1(n, data, is_prime)
  implicit none
  integer :: n, data(0:n-1), solutionPart1, i
  logical :: is_prime(n)
  integer, allocatable :: indices(:)
  indices = pack([(i, i=0,n-1)], is_prime)
  solutionPart1=sum(data(indices) * indices)
end function

function solutionPart2(n, data, is_prime)
  implicit none
  integer :: n, data(n), solutionPart2, signed(n), i, s
  logical :: is_prime(n)
  s = 1
  do i = 1, n
    signed(i) = s * data(i)
    s = -1 * s
  end do
  solutionPart2=sum(pack(signed, .not.is_prime))
end function

function isPrime(n)
  implicit none
  integer :: n, p
  logical :: isPrime
  do p = 2, int(sqrt(real(n)))
    if (mod(n, p) == 0) then
      isPrime = .false.
      return
    end if
  end do
  isPrime = .true.
end function

subroutine findPrimes(n, data, is_prime)
  implicit none
  integer :: n, data(n), i
  logical, intent(out) :: is_prime(n)
  logical :: isPrime
  do i = 1, n
    is_prime(i) = isPrime(data(i))
  end do
end subroutine

program aoc
  implicit none
  integer, allocatable :: data(:)
  logical, allocatable :: is_prime(:)
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
  allocate(is_prime(n))
  call findPrimes(n, data, is_prime)

  call get_environment_variable('part', part)
  if (trim(part).eq.'part1'.or.trim(part).eq.'') then
    print *, solutionPart1(n, data, is_prime)
  else if (trim(part).eq.'part2') then
    print *, solutionPart2(n, data, is_prime)
  else
    print *, 'Unknown part '//part
  end if
end program aoc