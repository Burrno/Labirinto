import numpy as np
cimport numpy as cnp
cimport cython
cnp.import_array()

DTYPE = np.int8
ctypedef cnp.int8_t DTYPE_t

cpdef int quant_viz_expand_especial(cnp.ndarray[DTYPE_t, ndim=2] arr, Py_ssize_t x, Py_ssize_t y):
    cdef Py_ssize_t m = arr.shape[0] - 1
    cdef Py_ssize_t n = arr.shape[1] - 1
    if x % m:
        if y % n:
            return (
                arr[x-1,y-1] + arr[x-1, y ] + arr[x-1,y+1] +
                arr[ x ,y-1] +                arr[ x ,y+1] +
                arr[x+1,y-1] + arr[x+1, y ] + arr[x+1,y+1]
            )
        elif y == 0:
            return (
                arr[x-1, y ] + arr[x-1,y+1] +
                               arr[ x ,y+1] +
                arr[x+1, y ] + arr[x+1,y+1]
            )
        else:  # y == n
            return (
                arr[x-1,y-1] + arr[x-1, y ] +
                arr[ x ,y-1] +               
                arr[x+1,y-1] + arr[x+1, y ]
            )
    elif x == 0:
        if y % n:
            return (
                arr[ x ,y-1] +                arr[ x ,y+1] +
                arr[x+1,y-1] + arr[x+1, y ] + arr[x+1,y+1]
            )
        elif y == 0:
            return (
                               arr[ x ,y+1] +
                arr[x+1, y ] + arr[x+1,y+1]
            )
        else:  # y == n
            return (
                arr[ x ,y-1] +             
                arr[x+1,y-1] + arr[x+1, y ]
            )
    else:  # x == m
        if y % n:
            return (
                arr[x-1,y-1] + arr[x-1, y ] + arr[x-1,y+1] +
                arr[ x ,y-1] +                arr[ x ,y+1]
            )
        elif y == 0:
            return (
                arr[x-1, y ] + arr[x-1,y+1]+
                               arr[ x ,y+1]
            )
        else:  # y == n
            return (
                arr[x-1,y-1] + arr[x-1, y ] +
                arr[ x ,y-1]
            )

@cython.wraparound(False)  # turn off negative index wrapping for entire function
@cython.boundscheck(False) # turn off bounds-checking for entire function
@cython.nonecheck(False)
cpdef list vizinhos_especial(cnp.ndarray[DTYPE_t, ndim=2] arr, Py_ssize_t x, Py_ssize_t y):
    cdef Py_ssize_t m = arr.shape[0] - 1
    cdef Py_ssize_t n = arr.shape[1] - 1
    cdef list vizinhos = []
    if x > 0:
        if arr[x-1,y]:
            vizinhos.append((x-1,y))
    if x < m:
        if arr[x+1,y]:
            vizinhos.append((x+1,y))
    if y > 0:
        if arr[x,y-1]:
            vizinhos.append((x,y-1))
    if y < n:
        if arr[x,y+1]:
            vizinhos.append((x,y+1))
    return vizinhos

@cython.wraparound(False)  # turn off negative index wrapping for entire function
@cython.boundscheck(False) # turn off bounds-checking for entire function
@cython.nonecheck(False)
cpdef list vizinhos_invertidos_especial(cnp.ndarray[DTYPE_t, ndim=2] arr, Py_ssize_t x, Py_ssize_t y):
    cdef Py_ssize_t m = arr.shape[0] - 1
    cdef Py_ssize_t n = arr.shape[1] - 1
    cdef list vizinhos = []
    if x > 0:
        if not arr[x-1,y]:
            vizinhos.append((x-1,y))
    if x < m:
        if not arr[x+1,y]:
            vizinhos.append((x+1,y))
    if y > 0:
        if not arr[x,y-1]:
            vizinhos.append((x,y-1))
    if y < n:
        if not arr[x,y+1]:
            vizinhos.append((x,y+1))
    return vizinhos

@cython.nonecheck(False)
cpdef Py_ssize_t dist_quad_int(Py_ssize_t v_0, Py_ssize_t v_1, Py_ssize_t elem_0, Py_ssize_t elem_1):
    return (v_0 - elem_0)**2 + (v_1 - elem_1)**2

@cython.nonecheck(False)
@cython.boundscheck(False) # turn off bounds-checking for entire function
cpdef Py_ssize_t densidade_local_especial(cnp.ndarray[DTYPE_t, ndim=2] arr, Py_ssize_t v_0, Py_ssize_t v_1):
        cdef Py_ssize_t n = 0
        cdef list lista_vizinho
        cdef tuple viz, vizinho
        lista_vizinho = vizinhos_invertidos_especial(arr, v_0, v_1)
        for viz in lista_vizinho:
            for vizinho in vizinhos_invertidos_especial(arr, viz[0], viz[1]):
                n += len(vizinhos_invertidos_especial(arr, vizinho[0], vizinho[1]))
        n = n*len(lista_vizinho)
        return -n

def vizinhos_ordenados(cnp.ndarray[DTYPE_t, ndim=2] arr, v_0: int, v_1: int, elem_0: np.int32, elem_1: np.int32) -> tuple:
    lista = vizinhos_especial(arr, v_0, v_1)
    tam = len(lista)
    if tam == 0 or tam == 1:
        return lista, tam
    else:
        return ordenar_esp(lista, tam, elem_0, elem_1), tam

@cython.nonecheck(False)
@cython.boundscheck(False) # turn off bounds-checking for entire function
cpdef list ordenar_esp(list lista, Py_ssize_t tam, cnp.int32_t elem_0, cnp.int32_t elem_1):
    cdef Py_ssize_t um, dois, tres, quatro
    if tam == 2:
        if dist_quad_int(lista[0][0], lista[0][1], elem_0, elem_1) <= dist_quad_int(lista[1][0], lista[1][1], elem_0, elem_1):
            return lista
        else:
            return [lista[1], lista[0]]
    elif tam == 3:
        um =   -dist_quad_int(lista[0][0], lista[0][1], elem_0, elem_1)
        dois = -dist_quad_int(lista[1][0], lista[1][1], elem_0, elem_1)
        tres = -dist_quad_int(lista[2][0], lista[2][1], elem_0, elem_1)
        if um >= dois:
            if tres >= um:
                return [lista[2], lista[0]]
            elif tres >= dois:
                return [lista[0], lista[2]]
            else:
                return [lista[0], lista[1]]
        else:
            if tres >= dois:
                return [lista[2], lista[1]]
            elif tres >= um:
                return [lista[1], lista[2]]
            else:
                return [lista[1], lista[0]]
    elif tam == 4:
        um =     -dist_quad_int(lista[0][0], lista[0][1], elem_0, elem_1)
        dois =   -dist_quad_int(lista[1][0], lista[1][1], elem_0, elem_1)
        tres =   -dist_quad_int(lista[2][0], lista[2][1], elem_0, elem_1)
        quatro = -dist_quad_int(lista[3][0], lista[3][1], elem_0, elem_1)
        if um >= dois:
            if tres >= um:
                if quatro >= tres:
                    return [lista[3], lista[2]]
                elif quatro >= um:
                    return [lista[2], lista[3]]
                else:
                    return [lista[2], lista[0]]
            elif tres >= dois:
                if quatro >= um:
                    return [lista[3], lista[0]]
                elif quatro >= tres:
                    return [lista[0], lista[3]]
                else:
                    return [lista[0], lista[2]]
            else:
                if quatro >= um:
                    return [lista[3], lista[0]]
                elif quatro >= dois:
                    return [lista[0], lista[3]]
                else:
                    return [lista[0], lista[1]]
        else:
            if tres >= dois:
                if quatro >= tres:
                    return [lista[3], lista[2]]
                elif quatro >= dois:
                    return [lista[2], lista[3]]
                else:
                    return [lista[2], lista[1]]
            elif tres >= um:
                if quatro >= dois:
                    return [lista[3], lista[1]]
                elif quatro >= tres:
                    return [lista[1], lista[3]]
                else:
                    return [lista[1], lista[2]]
            else:
                if quatro >= dois:
                    return [lista[3], lista[1]]
                elif quatro >= um:
                    return [lista[1], lista[3]]
                else:
                    return [lista[1], lista[0]]
