import lldb
import struct

def watch_double(debugger, command, result, internal_dict):
    """
    使用方法:
    (lldb) watch_double <addr> <target_val>
    例如:
    (lldb) watch_double 0x7ffee4b2a8c0 64.0
    """
    argv = command.split()
    if len(argv) != 2:
        print("用法: watch_double <addr> <target_val>")
        return

    addr = int(argv[0], 0)         # 允许 0x 前缀
    target_val = struct.unpack("d", struct.pack("Q", int(argv[1], 16)))[0]

    target = debugger.GetSelectedTarget()
    # 设置 watchpoint
    error = lldb.SBError()
    options = lldb.SBWatchpointOptions()
    options.SetWatchpointTypeRead(True)    # 监视读操作
    # options.SetWatchpointTypeWrite(True)   # 监视写操作
    # options.SetCondition("x > 5")          # 设置条件
    watchpoint = target.WatchpointCreateByAddress(addr, 8, options, error)
    watchpoint.SetCondition(f"*(double*){addr} == {target_val}")



def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
        "command script add -f lldb_custom_py.watch_double watch_double"
    )
    print(">>> 自定义命令 'watch_double' 已加载，用法: watch_double <addr> <target_val>")

