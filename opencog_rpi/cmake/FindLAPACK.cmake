#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

find_library(LAPACK_LIBRARY
	NAMES lapack
	PATH /usr/lib /usr/lib64 /usr/local/lib /usr/local/lib64)

find_library(F77BLAS_LIBRARY 
	NAMES f77blas
	PATH /usr/lib /usr/lib/atlas-base/ /usr/local/lib /usr/local/lib/atlas-base)

find_library(ATLAS_LIBRARY 
	NAMES atlas
	PATH /usr/lib /usr/lib/atlas-base /usr/local/lib /usr/local/lib/atlas-base)

if (LAPACK_LIBRARY AND F77BLAS_LIBRARY AND ATLAS_LIBRARY)
	SET(LAPACK_FOUND TRUE)
	LIST(APPEND LAPACK_LIBRARIES ${LAPACK_LIBRARY} 
				     ${F77BLAS_LIBRARY}
				     ${ATLAS_LIBRARY})
endif (LAPACK_LIBRARY AND F77BLAS_LIBRARY AND ATLAS_LIBRARY)

if ( LAPACK_FOUND )
	message( STATUS "Found LAPACK at ${LAPACK_LIBRARIES}")
else ( LAPACK_FOUND )
	message( STATUS "LAPACK not found")
endif ( LAPACK_FOUND )