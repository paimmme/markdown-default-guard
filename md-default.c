#include <CoreServices/CoreServices.h>
#include <stdio.h>
#include <string.h>

static const char *utis[] = {"com.unknown.md", "net.daringfireball.markdown"};

static void print_handler(CFStringRef uti) {
  char u[256] = "?", h[256] = "(none)";
  CFStringGetCString(uti, u, sizeof u, kCFStringEncodingUTF8);
  CFStringRef handler = LSCopyDefaultRoleHandlerForContentType(uti, kLSRolesAll);
  if (handler) { CFStringGetCString(handler, h, sizeof h, kCFStringEncodingUTF8); CFRelease(handler); }
  printf("%s\t%s\n", u, h);
}

int main(int argc, char **argv) {
  if (argc < 2) return 2;
  if (!strcmp(argv[1], "query") && argc >= 3) {
    CFStringRef uti = CFStringCreateWithCString(NULL, argv[2], kCFStringEncodingUTF8);
    print_handler(uti); CFRelease(uti); return 0;
  }
  if (!strcmp(argv[1], "set") && argc >= 3) {
    CFStringRef bid = CFStringCreateWithCString(NULL, argv[2], kCFStringEncodingUTF8);
    int rc = 0;
    for (int i = 0; i < 2; i++) {
      CFStringRef uti = CFStringCreateWithCString(NULL, utis[i], kCFStringEncodingUTF8);
      if (LSSetDefaultRoleHandlerForContentType(uti, kLSRolesAll, bid) != noErr) rc = 1;
      CFRelease(uti);
    }
    for (int i = 0; i < 2; i++) {
      CFStringRef uti = CFStringCreateWithCString(NULL, utis[i], kCFStringEncodingUTF8);
      CFStringRef got = LSCopyDefaultRoleHandlerForContentType(uti, kLSRolesAll);
      char g[256] = ""; if (got) { CFStringGetCString(got, g, sizeof g, kCFStringEncodingUTF8); CFRelease(got); }
      char want[256] = ""; CFStringGetCString(bid, want, sizeof want, kCFStringEncodingUTF8);
      if (strcasecmp(g, want)) rc = 1;
      CFRelease(uti);
    }
    CFRelease(bid); return rc;
  }
  return 2;
}
