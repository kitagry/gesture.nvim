import { Neovim, Window } from "neovim";
import { TabpageRepository } from "./tabpage";

describe("TabpageRepository", () => {
  it("getGlobalPosition", async () => {
    const call = jest.fn().mockImplementation(name => {
      switch (name) {
        case "win_screenpos":
          return [1, 1];
        case "wincol":
          return 10;
        case "winline":
          return 20;
        default:
          return -8888;
      }
    });

    const WindowClass: jest.Mock<Window> = jest.fn(() => ({
      id: 1,
    })) as any;
    const win = new WindowClass();

    const window = jest.fn().mockImplementation(async () => {
      return win;
    })();

    const NeovimClass: jest.Mock<Neovim> = jest.fn(() => ({
      window: window,
      call: call,
    })) as any;
    const vim = new NeovimClass();

    const tabpageRepository = new TabpageRepository(vim);

    const result = await tabpageRepository.getGlobalPosition();

    expect(result).toEqual({ x: 11, y: 21 });
  });
});
