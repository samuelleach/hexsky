pro solve_ax_equals_b,A,B,X
  
  ;AUTHOR: S. Leach
  ;PURPOSE: Wrapper routine to linear solver Ax=b
  ;Adapted from http://idlastro.gsfc.nasa.gov/idl_html_help/LINBCG.html
  
  ; Solve the linear system Ax=b:
  result = LINBCG(SPRSIN(A), B, X)

  X = result
  
end

pro test_solve_ax_equals_b

  ; Begin with an array A:
  A = [[ 5.0,  0.0, 0.0,  1.0, -2.0], $
     [ 3.0, -2.0, 0.0,  1.0,  0.0], $
     [ 4.0, -1.0, 0.0,  2.0,  0.0], $
     [ 0.0,  3.0, 3.0,  1.0,  0.0], $
     [-2.0,  0.0, 0.0, -1.0,  2.0]]
  
  ; Define a right-hand side vector B:
  B = [7.0, 1.0, 3.0, 3.0, -4.0]
  
  ; Start with an initial guess at the solution:
  X = REPLICATE(1.0, N_ELEMENTS(B))
  
  solve_ax_equals_b,A,B,X

  print,X

;   The exact solution is [1, 1, 0, 0, -1].
  
  
end