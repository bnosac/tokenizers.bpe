## CHANGES IN tokenizers.bpe VERSION 0.1.6

- Update parallel-hashmap to commit 48f4c5fb0519e41233f000340039a1a9dd00a1f0 as it fixes the same as what tokenizers.bpe 0.1.5 fixed but now upstream

## CHANGES IN tokenizers.bpe VERSION 0.1.5

- phmap_base.h: replace 
    using GetIsAlwaysEqual = typename T::is_always_equal;
    with  GetIsAlwaysEqual = typename std::allocator_traits<T>::is_always_equal;
  to avoid warning: 'is_always_equal' is deprecated on Debian clang version 21.1.8

## CHANGES IN tokenizers.bpe VERSION 0.1.4

- Update parallel-hashmap to commit 88123934b46b77c3b6d80167382734cbff6eff74 to fix clang 21.1.0 compiler warnings 'pointer' and 'const_pointer' is deprecated

## CHANGES IN tokenizers.bpe VERSION 0.1.3

- Update parallel-hashmap to 1.3.11 which fixes C++17 deprecations about rebind, construct, destroy

## CHANGES IN tokenizers.bpe VERSION 0.1.2

- Drop C++11 specification in Makevars

## CHANGES IN tokenizers.bpe VERSION 0.1.1

- replace move with std::move to fix R CMD check warning on recent versions of clang compilers

## CHANGES IN tokenizers.bpe VERSION 0.1.0

- Initial package based on VKCOM/YouTokenToMe version 1.0.1 commit 16fcf1d8e208f9bbbc9f522e83e6ff81708dba73
