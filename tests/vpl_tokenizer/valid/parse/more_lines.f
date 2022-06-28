!! Code extracted at https://github.com/scivision/fortran2018-examples/blob/main/src/array/auto_allocate.f90
!! to just test tokenizer with a Fortran example.

program auto_allocate
    !! demonstrate Fortran 2003 automatic allocation of arrays
    !!
    !! NOTE: even if an array allocate(), Fortran 2003 still allows auto-reallocation bigger or smaller
    !! The A(:) syntax preserves previously allocated LHS shape, truncating RHS

    use, intrinsic :: iso_fortran_env, only : stderr=>error_unit, compiler_options
    implicit none (type, external)

    real, allocatable, dimension(:) :: A, B, C, D, E
    real :: C3(3)

    print *, compiler_options()

    !> Initial auto-allocate
    A = [1,2,3]
    B = [4,5,6]

    C3 = A + B
    C = A + B
    if (any(C3 /= C)) error stop 'initial auto-allocate'
    if (size(C) /= 3) error stop 'initial auto-alloc size'

    !> allocate bigger
    A = [1,2,3,4]
    B = [5,6,7,8]
    C = A + B
    if (any(C /= [6,8,10,12])) error stop 'auto-alloc smaller'
    if (size(C) /= 4) error stop 'auto-alloc bigger size'

    !> allocate smaller
    A = [1,2]
    B = [3,4]
    C = A + B
    if (any(C /= [4,6])) error stop 'auto-alloc smaller'
    if (size(C) /= 2) error stop 'auto-alloc smaller size'

    !> fixed allocate first
    allocate(D(3), E(3))
    D = [1,2]
    E = [3,4,5,7]

    if (size(D) /= 2) error stop 'allocate() auto-allocate small'
    if (size(E) /= 4) error stop 'allocate() auto-allocate big'

    !> (:) syntax truncates, does not change shape, whether or not allocate() used first
    A(:) = [9,8,7]
    if (size(A) /= 2) error stop '(:) syntax smaller'
    if (any(A /= [9,8])) error stop '(:) assign small'

    E(:) = [1,2,3]
    if (size(E) /= 4) error stop 'allocate() (:) syntax small'
    if (any(E /= [1,2,3,7])) error stop 'allocate() (:) assign small'

    E(:) = [5,4,3,2,1]
    if (size(E) /= 4) error stop 'allocate() (:) syntax: big'
    if (any(E /= [5,4,3,2])) error stop 'allocate() (:) assign: big'

    !> (lbound:ubound)
    ! A(1:3) = [4,5,6]
    ! gfortran -fcheck=bounds
    ! Fortran runtime error: Index '3' of dimension 1 of array 'a' outside of expected range (2:1)
    ! ifort -CB
    ! forrtl: severe (408): fort: (10): Subscript #1 of the array A has value 3 which is greater than the upper bound of 2
    if (size(A) /= 2) error stop '(l:u) syntax smaller'

    print *, 'OK: auto-allocate array'
end program