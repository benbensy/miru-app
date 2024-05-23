class Element {
  constructor(content, selector) {
    this.content = content;
    this.selector = selector || "";
  }
  async querySelector(selector) {
    return new Element(await this.execute(), selector);
  }

  async execute(fun) {
    return await handlePromise("querySelector$className", JSON.stringify([this.content, this.selector, fun]));
  }

  async removeSelector(selector) {
    this.content = await handlePromise("removeSelector$className", JSON.stringify([await this.outerHTML, selector]));
    return this;
  }

  async getAttributeText(attr) {
    return await handlePromise("getAttributeText$className", JSON.stringify([await this.outerHTML, this.selector, attr]));
  }

  get text() {
    return this.execute("text");
  }

  get outerHTML() {
    return this.execute("outerHTML");
  }

  get innerHTML() {
    return this.execute("innerHTML");
  }
}
class XPathNode {
  constructor(content, selector) {
    this.content = content;
    this.selector = selector;
  }

  async excute(fun) {
    return await handlePromise("queryXPath$className", JSON.stringify([this.content, this.selector, fun]));
  }

  get attr() {
    return this.excute("attr");
  }

  get attrs() {
    return this.excute("attrs");
  }

  get text() {
    return this.excute("text");
  }

  get allHTML() {
    return this.excute("allHTML");
  }

  get outerHTML() {
    return this.excute("outerHTML");
  }
}

// 重写 console.log
console.log = function (message) {
  if (typeof message === "object") {
    message = JSON.stringify(message);
  }
  DartBridge.sendMessage("log$className", JSON.stringify([message.toString()]));
};
class Extension {
  package = "${extension.package}";
  name = "${extension.name}";
  // 在 load 中注册的 keys
  settingKeys = [];

  querySelector(content, selector) {
    return new Element(content, selector);
  }
  async request(url, options) {
    options = options || {};
    options.headers = options.headers || {};
    const miruUrl = options.headers["Miru-Url"] || "${extension.webSite}";
    options.method = options.method || "get";
    const message = await handlePromise("request$className", JSON.stringify([miruUrl + url, options, "${extension.package}"]));
    try {
      return JSON.parse(message);
    } catch (e) {
      return message;
    }
  }
  queryXPath(content, selector) {
    return new XPathNode(content, selector);
  }
  async querySelectorAll(content, selector) {
    const arg = await handlePromise("querySelectorAll$className", JSON.stringify({ content: content, selector: selector }));
    const message = JSON.parse(arg);
    const elements = [];
    for (const e of message) {
      elements.push(new Element(e, selector));
    }
    return elements;
  }
  async getAttributeText(content, selector, attr) {
    const waitForChange = new Promise(resolve => {
      DartBridge.setHandler("getAttributeText$className", async (arg) => {
        resolve(arg);
      })
    });
    DartBridge.sendMessage("getAttributeText$className", JSON.stringify([content, selector, attr]));
    const elements = await waitForChange;
    return elements;
  }
  latest(page) {
    throw new Error("not implement latest");
  }
  search(kw, page, filter) {
    throw new Error("not implement search");
  }
  createFilter(filter) {
    throw new Error("not implement createFilter");
  }
  detail(url) {
    throw new Error("not implement detail");
  }
  watch(url) {
    throw new Error("not implement watch");
  }
  checkUpdate(url) {
    throw new Error("not implement checkUpdate");
  }
  async getSetting(key) {
    return await handlePromise("getSetting$className", JSON.stringify([key]));
  }
  async registerSetting(settings) {
    console.log(JSON.stringify([settings]));
    this.settingKeys.push(settings.key);
    return await handlePromise("registerSetting$className", JSON.stringify([settings]));
  }
  async load() { }
}
async function handlePromise(channelName, message) {
  const waitForChange = new Promise(resolve => {
    DartBridge.setHandler(channelName, async (arg) => {
      resolve(arg);
    })
  });
  DartBridge.sendMessage(channelName, message);
  return await waitForChange
}
async function stringify(callback) {
  const data = await callback();
  return typeof data === "object" ? JSON.stringify(data, 0, 2) : data;
}
