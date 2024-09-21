# Extracted from https://github.com/mjblack/win32cr/blob/master/src/win32cr/ui/windowsandmessaging.cr

{% if flag?(:win32) %}
  @[Link("user32")]
  @[Link("mrmsupport")]
  lib LibWin32
    enum SYSTEM_PARAMETERS_INFO_ACTION : UInt32
      SPI_SETDESKWALLPAPER = 20
    end

    enum SYSTEM_PARAMETERS_INFO_UPDATE_FLAGS : UInt32
      SPIF_UPDATEINIFILE = 1
      SPIF_SENDCHANGE    = 2
    end

    enum SYSTEM_METRICS_INDEX : UInt32
      SM_CXSCREEN = 0
      SM_CYSCREEN = 1
    end

    fun SystemParametersInfoA(
      uiaction : SYSTEM_PARAMETERS_INFO_ACTION,
      uiparam : UInt32,
      pvparam : Void*,
      fwinini : SYSTEM_PARAMETERS_INFO_UPDATE_FLAGS
    ) : LibC::BOOL

    fun GetSystemMetrics(nindex : SYSTEM_METRICS_INDEX) : Int32
  end
{% end %}
