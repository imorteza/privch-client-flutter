# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.
cmake_minimum_required(VERSION 3.18)

# Declares and names the project.
project("Xinlake-Tunnel")

find_library(
    # Sets the name of the path variable.
    log-lib

    # Specifies the name of the NDK library that
    # you want CMake to locate.
    log)

set(DIR_LIBANCILLARY libancillary)
add_library(
    libancillary STATIC

    ${DIR_LIBANCILLARY}/fd_recv.c
    ${DIR_LIBANCILLARY}/fd_send.c
)

set(DIR_BADVPN badvpn)
add_executable(
    libtun2socks.so

    ${DIR_BADVPN}/base/BLog_syslog.c
    ${DIR_BADVPN}/base/DebugObject.c
    ${DIR_BADVPN}/base/BLog.c
    ${DIR_BADVPN}/base/BPending.c
    ${DIR_BADVPN}/system/BReactor_badvpn.c
    ${DIR_BADVPN}/system/BSignal.c
    ${DIR_BADVPN}/system/BConnection_common.c
    ${DIR_BADVPN}/system/BConnection_unix.c
    ${DIR_BADVPN}/system/BTime.c
    ${DIR_BADVPN}/system/BUnixSignal.c
    ${DIR_BADVPN}/system/BNetwork.c
    ${DIR_BADVPN}/system/BDatagram_unix.c
    ${DIR_BADVPN}/flow/StreamRecvInterface.c
    ${DIR_BADVPN}/flow/PacketRecvInterface.c
    ${DIR_BADVPN}/flow/PacketPassInterface.c
    ${DIR_BADVPN}/flow/StreamPassInterface.c
    ${DIR_BADVPN}/flow/SinglePacketBuffer.c
    ${DIR_BADVPN}/flow/BufferWriter.c
    ${DIR_BADVPN}/flow/PacketBuffer.c
    ${DIR_BADVPN}/flow/PacketStreamSender.c
    ${DIR_BADVPN}/flow/PacketPassConnector.c
    ${DIR_BADVPN}/flow/PacketProtoFlow.c
    ${DIR_BADVPN}/flow/PacketPassFairQueue.c
    ${DIR_BADVPN}/flow/PacketProtoEncoder.c
    ${DIR_BADVPN}/flow/PacketProtoDecoder.c
    ${DIR_BADVPN}/lwip/src/core/udp.c
    ${DIR_BADVPN}/lwip/src/core/memp.c
    ${DIR_BADVPN}/lwip/src/core/init.c
    ${DIR_BADVPN}/lwip/src/core/pbuf.c
    ${DIR_BADVPN}/lwip/src/core/tcp.c
    ${DIR_BADVPN}/lwip/src/core/tcp_out.c
    ${DIR_BADVPN}/lwip/src/core/netif.c
    ${DIR_BADVPN}/lwip/src/core/def.c
    ${DIR_BADVPN}/lwip/src/core/ip.c
    ${DIR_BADVPN}/lwip/src/core/mem.c
    ${DIR_BADVPN}/lwip/src/core/tcp_in.c
    ${DIR_BADVPN}/lwip/src/core/stats.c
    ${DIR_BADVPN}/lwip/src/core/inet_chksum.c
    ${DIR_BADVPN}/lwip/src/core/timeouts.c
    ${DIR_BADVPN}/lwip/src/core/ipv4/icmp.c
    ${DIR_BADVPN}/lwip/src/core/ipv4/igmp.c
    ${DIR_BADVPN}/lwip/src/core/ipv4/ip4_addr.c
    ${DIR_BADVPN}/lwip/src/core/ipv4/ip4_frag.c
    ${DIR_BADVPN}/lwip/src/core/ipv4/ip4.c
    ${DIR_BADVPN}/lwip/src/core/ipv4/autoip.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/ethip6.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/inet6.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/ip6_addr.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/mld6.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/dhcp6.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/icmp6.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/ip6.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/ip6_frag.c
    ${DIR_BADVPN}/lwip/src/core/ipv6/nd6.c
    ${DIR_BADVPN}/lwip/custom/sys.c
    ${DIR_BADVPN}/tun2socks/tun2socks.c
    ${DIR_BADVPN}/tun2socks/SocksUdpGwClient.c
    ${DIR_BADVPN}/flowextra/PacketPassInactivityMonitor.c
    ${DIR_BADVPN}/socksclient/BSocksClient.c
    ${DIR_BADVPN}/tuntap/BTap.c
    ${DIR_BADVPN}/udpgw_client/UdpGwClient.c
)

target_include_directories(
    libtun2socks.so

    PRIVATE ${DIR_LIBANCILLARY}
    PRIVATE ${DIR_BADVPN}/lwip/src/include/ipv4
    PRIVATE ${DIR_BADVPN}/lwip/src/include/ipv6
    PRIVATE ${DIR_BADVPN}/lwip/src/include
    PRIVATE ${DIR_BADVPN}/lwip/custom
    PRIVATE ${DIR_BADVPN}
)

target_link_libraries(
    libtun2socks.so

    libancillary
    ${log-lib}
)

target_compile_definitions(
    libtun2socks.so
    PRIVATE BADVPN_THREADWORK_USE_PTHREAD BADVPN_LINUX BADVPN_BREACTOR_BADVPN _GNU_SOURCE
    PRIVATE BADVPN_USE_SIGNALFD BADVPN_USE_EPOLL
    PRIVATE BADVPN_LITTLE_ENDIAN BADVPN_THREAD_SAFE
    PRIVATE NDEBUG ANDROID
)

set_property(TARGET libtun2socks.so PROPERTY C_STANDARD 99)
