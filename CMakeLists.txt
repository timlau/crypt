#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.15)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.12 CACHE STRING "Minimum OS X deployment version" FORCE)

project(Crypt2SynthPlugin VERSION 2.1.0)

# Enable compile commands export for IDEs
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(cmake/CPM.cmake)
CPMAddPackage("gh:/juce-framework/JUCE#8.0.11")
CPMAddPackage("gh:/free-audio/clap-juce-extensions#main")
#
# Copy plugins after build option
option(CRYPT_COPY_PLUGIN_AFTER_BUILD "Copy JUCE Plugins after built" ON)

# ==================== Add Plugin =======================
# Build LV2 only on Linux
set(JUCE_FORMATS AU VST3 Standalone)
if(UNIX AND NOT APPLE)
  list(APPEND JUCE_FORMATS LV2)
endif()

juce_add_plugin(${PROJECT_NAME}
        VERSION 2.1.0                               # Set this if the plugin version is different to the project version
        ICON_BIG ${CMAKE_CURRENT_SOURCE_DIR}/resources/crypt-icon.png                              # ICON_* arguments specify a path to an image file to use as an icon for the Standalone
        ICON_SMALL ${CMAKE_CURRENT_SOURCE_DIR}/resources/crypt-icon.png
        COMPANY_NAME Vitling                          # Specify the name of the plugin's author
        IS_SYNTH TRUE                       # Is this a synth or an effect?
        NEEDS_MIDI_INPUT TRUE               # Does the plugin need midi input?
        NEEDS_MIDI_OUTPUT FALSE              # Does the plugin need midi output?
        IS_MIDI_EFFECT FALSE                 # Is this plugin a MIDI effect?
        EDITOR_WANTS_KEYBOARD_FOCUS FALSE    # Does the editor need keyboard focus?
        COPY_PLUGIN_AFTER_BUILD ${CRYPT_COPY_PLUGIN_AFTER_BUILD}        # Should the plugin be installed to a default location after building?
        PLUGIN_MANUFACTURER_CODE Vitl               # A four-character manufacturer id with at least one upper-case character
        PLUGIN_CODE Crp2                            # A unique four-character plugin id with at least one upper-case character
        DESCRIPTION "Hyper-Unison Synthesiser from Bow Church/Vitling"
        VST3_CATEGORIES "Instrument Synth Stereo"
        AU_MAIN_TYPE "kAudioUnitType_MusicDevice"
        FORMATS ${JUCE_FORMATS}
        BUNDLE_ID "xyz.vitling.plugins.crypt2"
        HARDENED_RUNTIME_ENABLED TRUE
        LV2URI "https://github.com/vitling/crypt"
        PRODUCT_NAME "Crypt2")        # The name of the final executable, which can differ from the target name


# ==================== CLAP =======================
clap_juce_extensions_plugin(TARGET ${PROJECT_NAME}
      CLAP_ID "xyz.vitling.plugins.crypt2"
      CLAP_FEATURES instrument "virtual analog"
)

juce_generate_juce_header(${PROJECT_NAME})

target_sources(${PROJECT_NAME} PRIVATE
        src/CryptPlugin.cpp)

target_compile_definitions(${PROJECT_NAME}
        PUBLIC
        JUCE_WEB_BROWSER=0
        JUCE_USE_CURL=0
        JUCE_VST3_CAN_REPLACE_VST2=0

        # We don't have to display the splash screen since we're using JUCE
        # under the GPL
        # JUCE_DISPLAY_SPLASH_SCREEN=0
)

juce_add_binary_data(${PROJECT_NAME}Data SOURCES resources/Gothica-Book.ttf resources/bg.jpg resources/presets.xml resources/keyboard-icon.png)
set_target_properties(${PROJECT_NAME}Data PROPERTIES POSITION_INDEPENDENT_CODE ON)

target_link_libraries(${PROJECT_NAME} PRIVATE
        Crypt2SynthPluginData
        juce::juce_audio_utils
        juce::juce_dsp)


# ==================== Installation =======================
include(GNUInstallDirs)

# Install the standalone application
if(TARGET ${PROJECT_NAME}_Standalone)
  install(TARGETS ${PROJECT_NAME}_Standalone DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()

# Install the native Juce plugins
foreach(format VST3 LV2)
  if(TARGET ${PROJECT_NAME}_${format})
    get_target_property(output ${PROJECT_NAME}_${format} JUCE_PLUGIN_ARTEFACT_FILE)
    install(DIRECTORY ${output} DESTINATION ${CMAKE_INSTALL_LIBDIR}/$<LOWER_CASE:${format}>)
  endif()
endforeach()

# Install the CLAP plugin
if(TARGET ${PROJECT_NAME}_CLAP)
  install(TARGETS ${PROJECT_NAME}_CLAP DESTINATION ${CMAKE_INSTALL_LIBDIR}/clap)
endif()

