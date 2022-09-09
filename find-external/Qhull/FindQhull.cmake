# .rst: FindQhull
# --------
#
# based on
# https://github.com/PointCloudLibrary/pcl/blob/master/cmake/Modules/FindQhull.cmake
#
# Try to find QHULL library and headers. This module supports both old released
# versions of QHULL ≤ 7.3.2 and newer development versions that ship with a
# modern config file, but its limited to only the reentrant version of Qhull.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
#
# This module defines the :prop_tgt:`IMPORTED` targets:
#
# ``QHULL::QHULL`` Defined if the system has QHULL.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module sets the following variables:
#
# ::
#
# QHULL_FOUND               True in case QHULL is found, otherwise false
#
# Example usage
# ^^^^^^^^^^^^^
#
# ::
#
# find_package(QHULL REQUIRED)
#
# add_executable(foo foo.cc) target_link_libraries(foo QHULL::QHULL)
#

# Skip if QHULL::QHULL is already defined
if(TARGET QHULL::QHULL)
  return()
endif()

# Try to locate QHull using modern cmake config (available on latest Qhull
# version).
find_package(Qhull CONFIG QUIET)

if(Qhull_FOUND AND TARGET Qhull::qhull_r)
  add_library(QHULL::QHULL INTERFACE IMPORTED)
  set_property(
    TARGET QHULL::QHULL
    APPEND
    PROPERTY INTERFACE_LINK_LIBRARIES Qhull::qhull_r)
  message(STATUS "QHULL found")
  return()
endif()

find_file(
  QHULL_HEADER
  NAMES libqhull_r.h
  HINTS "${QHULL_ROOT}" "$ENV{QHULL_ROOT}" "${QHULL_INCLUDE_DIR}"
  PATH_SUFFIXES qhull_r src/libqhull_r libqhull_r include)

set(QHULL_HEADER
    "${QHULL_HEADER}"
    CACHE INTERNAL "QHull header" FORCE)

if(QHULL_HEADER)
  get_filename_component(qhull_header ${QHULL_HEADER} NAME_WE)
  if("${qhull_header}" STREQUAL "qhull_r")
    get_filename_component(QHULL_INCLUDE_DIR ${QHULL_HEADER} PATH)
  elseif("${qhull_header}" STREQUAL "libqhull_r")
    get_filename_component(QHULL_INCLUDE_DIR ${QHULL_HEADER} PATH)
    get_filename_component(QHULL_INCLUDE_DIR ${QHULL_INCLUDE_DIR} PATH)
  endif()
else()
  set(QHULL_INCLUDE_DIR "QHULL_INCLUDE_DIR-NOTFOUND")
endif()

find_library(
  QHULL_LIBRARY
  NAMES qhull_r qhull
  HINTS "${QHULL_ROOT}" "$ENV{QHULL_ROOT}"
  PATH_SUFFIXES project build bin lib)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  Qhull
  FOUND_VAR QHULL_FOUND
  REQUIRED_VARS QHULL_LIBRARY QHULL_INCLUDE_DIR)

if(QHULL_FOUND)
  add_library(QHULL::QHULL SHARED IMPORTED)
  set_target_properties(
    QHULL::QHULL
    PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${QHULL_INCLUDE_DIR}"
               IMPORTED_LOCATION_RELEASE "${QHULL_LIBRARY}"
               IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")
  message(
    STATUS "QHULL found (include: ${QHULL_INCLUDE_DIR}, lib: ${QHULL_LIBRARY})")
endif()
